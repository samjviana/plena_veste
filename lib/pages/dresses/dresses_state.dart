import 'package:flutter/material.dart';
import 'package:plena_veste/database/bigquery_service.dart';
import 'package:plena_veste/database/models/dress.dart';
import 'package:plena_veste/di.dart';

class DressesState extends ChangeNotifier {
    final BigQueryService bigQueryService = getIt<BigQueryService>();

    final List<Dress> dresses = [];
}