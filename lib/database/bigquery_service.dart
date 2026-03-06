import 'dart:convert';

import 'package:googleapis/bigquery/v2.dart';
import 'package:plena_veste/auth/oauth_service.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/di.dart';
import 'package:flutter/foundation.dart';

class BigQueryService {
    static const String _projectId = 'plena-veste-voce';
    static const String _datasetId = kReleaseMode ? 'dataset_prod' : 'dataset_dev';
    static const String _location = 'southamerica-east1';
    // TODO: Search about reflection in Dart to write this in a more robust way, as it can get cluttered as more models are added
    static const Map<String, Map<String, String> Function()> _tables = {
        'dresses': Dress.tableFields,
    };

    late BigqueryApi _api;


    Future<bool> initialize() async {
        _api = BigqueryApi(await getIt<GoogleOAuthService>().authenticatedClient());

        await _initDataset();
        await _initTables();
        // await insertDemoData();
        
        return true;
    }

    Future<void> _initDataset() async {
        Dataset? dataset;
        try {
            dataset = await _api.datasets.get(_projectId, _datasetId);
        } on DetailedApiRequestError catch (ex) {
            if (ex.status != 404) {
                rethrow;
            }
        }

        if (dataset != null) {
            return;
        }

        dataset = Dataset(
            datasetReference: DatasetReference(datasetId: _datasetId, projectId: _projectId),
            location: _location,
        );
        await _api.datasets.insert(dataset, _projectId);
    }

    Future<void> _initTables() async {
        final TableList tables = await _api.tables.list(_projectId, _datasetId);
        for (final entry in _tables.entries) {
            final String tableId = entry.key;
            final Map<String, String> Function() fieldsProvider = entry.value;

            if (tables.tables != null && tables.tables!.any((table) => table.tableReference!.tableId == tableId)) {
                continue;
            }

            // TODO: This is another callback to the problem of having the schema returned from the model as a Map
            final Map<String, String> fields = fieldsProvider();
            final TableSchema schema = TableSchema(
                fields: fields.entries.map((entry) => TableFieldSchema(
                    name: entry.key,
                    type: entry.value,
                    mode: entry.key == 'photos' ? 'REPEATED' : null,
                )).toList(),
            );
            final Table table = Table(
                tableReference: TableReference(tableId: tableId, datasetId: _datasetId, projectId: _projectId),
                schema: schema,
            );

            await _api.tables.insert(table, _projectId, _datasetId);
        }
    }

    Future<void> insertDemoData() async {
        Dress dress = Dress(
            code: '20001',
            model: 'Vestido Longo',
            category: DressCategory.party,
            length: DressLength.long,
            color: 'Azul',
            size: 42,
            isAdjustable: true,
            purchasePrice: 39990,
            rentalPrice: 30000,
            depositValue: 10000,
            timesRented: 0,
            lastRentedAt: DateTime(2026, 03, 01),
            currentStatus: DressStatus.available,
        );

        await insert(Dress.tableId, dress.toMap());
    }

    Future<bool> insert(String tableId, Map<String, dynamic> values) async {
        final String json = '${jsonEncode(values)}\n';
        final List<int> bytes = utf8.encode(json);

        final Media media = Media(
            Stream<List<int>>.value(bytes),
            bytes.length,
            contentType: 'application/octet-stream',
        );

        final Job job = Job(
            jobReference: JobReference(projectId: _projectId, location: _location),
            configuration: JobConfiguration(
                load: JobConfigurationLoad(
                    destinationTable: TableReference(
                        projectId: _projectId,
                        datasetId: _datasetId,
                        tableId: tableId,
                    ),
                    sourceFormat: 'NEWLINE_DELIMITED_JSON',
                    writeDisposition: 'WRITE_APPEND',
                    createDisposition: 'CREATE_NEVER',
                ),
            ),
        );
        final Job started = await _api.jobs.insert(job, _projectId, uploadMedia: media);
        final String? jobId = started.jobReference?.jobId;
        if (jobId == null) {
            throw Exception('BigQuery: jobId veio null ao iniciar o load job.');
        }

        while (true) {
            final Job current = await _api.jobs.get(_projectId, jobId, location: _location);
            final String? state = current.status?.state;

            if (state == 'DONE') {
                final errors = current.status?.errors;
                if (errors != null && errors.isNotEmpty) {
                    print('BigQuery load job falhou: ${errors.map((e) => e.message).join(' | ')}');
                    throw Exception(
                        'BigQuery load job falhou: ${errors.map((e) => e.message).join(' | ')}',
                    );
                }
                break;
            }

            await Future.delayed(const Duration(milliseconds: 400));
        }

        return true;
    }

    // TODO: This method was generated by ChatGPT, although it is very simple and concise it is necessary to review it and double check if its really the best approach
    dynamic _unwrapBigQueryValue(dynamic v) {
        if (v == null) return null;

        // ARRAY fields come as List of {"v": ...}
        if (v is List) {
            return v.map(_unwrapBigQueryValue).toList();
        }

        // Scalar cells often come as {"v": ...}
        if (v is Map<String, dynamic> && v.containsKey('v') && v.length == 1) {
            return _unwrapBigQueryValue(v['v']);
        }

        return v;
    }

    Future<List<T>> selectAll<T>(String tableId, T Function(Map<String, dynamic>) fromMap) async {
        final String query = 'SELECT * FROM `$_projectId.$_datasetId.$tableId`';
        final QueryResponse response = await _api.jobs.query(
            QueryRequest(query: query),
            _projectId
        );

        final List<Map<String, dynamic>> rows = response.rows?.map((row) {
            final Map<String, dynamic> map = {};
            for (int i = 0; i < (response.schema?.fields?.length ?? 0); i++) {
                final String? fieldName = response.schema?.fields?[i].name;
                if (fieldName != null) {
                    map[fieldName] = _unwrapBigQueryValue(row.f?[i].v);
                }
            }
            return map;
        }).toList() ?? [];

        List<T> result = [];
        for (final row in rows) {
            try {
                result.add(fromMap(row));
            } catch (e) {
                print('Error parsing row: $e');
                print('Row data: $row');
            }
        }
        return result;
    }
}