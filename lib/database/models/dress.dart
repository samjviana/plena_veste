import 'dart:convert';
import 'dart:typed_data';

import 'package:plena_veste/database/models/base_model.dart';
import 'package:uuid/uuid.dart';

DateTime parseBigQueryTimestamp(dynamic value) {
    // BigQuery TIMESTAMP (via JSON) às vezes vem como num ou string em notação científica
    final num seconds = value is num ? value : num.parse(value.toString());

    // Robustez: detecta unidade pelo tamanho
    // ~1e9  = seconds
    // ~1e12 = milliseconds
    // ~1e15 = microseconds
    int microsSinceEpoch;
    if (seconds.abs() >= 1e14) {
        // already microseconds
        microsSinceEpoch = seconds.round();
    } else if (seconds.abs() >= 1e11) {
        // milliseconds -> microseconds
        microsSinceEpoch = (seconds * 1000).round();
    } else {
        // seconds -> microseconds
        microsSinceEpoch = (seconds * 1000000).round();
    }

    return DateTime.fromMicrosecondsSinceEpoch(microsSinceEpoch, isUtc: true);
}

class Dress extends BaseModel {
    static const String tableId = 'dresses';

    String code;
    String model;
    DressCategory category;
    DressLength length;
    String color;
    int size;
    bool isAdjustable;
    int purchasePrice;
    int rentalPrice;
    int depositValue;
    int? sellingPrice;
    int timesRented;
    DateTime? lastRentedAt;
    DressStatus currentStatus;
    List<Uint8List>? photos;
    String? notes;

    Dress({
        String? uuid,
        required this.code,
        required this.model,
        required this.category,
        required this.length,
        required this.color,
        required this.size,
        required this.isAdjustable,
        required this.purchasePrice,
        required this.rentalPrice,
        required this.depositValue,
        this.sellingPrice,
        required this.timesRented,
        this.lastRentedAt,
        required this.currentStatus,
        this.notes,
        this.photos,
        DateTime? createdAt,
        DateTime? updatedAt,
    }) : super(
        uuid: uuid ?? const Uuid().v4(),
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt ?? DateTime.now(),
    );

    factory Dress.fromMap(Map<String, dynamic> map) {
        return Dress(
            uuid: map['uuid'],
            code: map['code'],
            model: map['model'],
            category: DressCategory.values.firstWhere((value) => value.name == map['category']),
            length: DressLength.values.firstWhere((value) => value.name == map['length']),
            color: map['color'],
            size: int.parse(map['size'].toString()),
            isAdjustable: map['isAdjustable'].toString().toLowerCase() == 'true',
            purchasePrice: int.parse(map['purchasePrice'].toString()),
            rentalPrice: int.parse(map['rentalPrice'].toString()),
            depositValue: int.parse(map['depositValue'].toString()),
            sellingPrice: map['sellingPrice'] != null ? int.parse(map['sellingPrice'].toString()) : null,
            timesRented: int.parse(map['timesRented'].toString()),
            lastRentedAt: map['lastRentedAt'] != null ? DateTime.parse(map['lastRentedAt']) : null,
            currentStatus: DressStatus.values.firstWhere((value) => value.name == map['currentStatus']),
            notes: map['notes'],
            photos: map['photos'] != null ? List<Uint8List>.from(map['photos'].map((photo) => Uint8List.fromList(base64Decode(photo)))) : null,
            createdAt: map['createdAt'] != null ? parseBigQueryTimestamp(map['createdAt']) : null,
            updatedAt: map['updatedAt'] != null ? parseBigQueryTimestamp(map['updatedAt']) : null,
        );
    }

    @override
    Map<String, dynamic> toMap() {
        final baseMap = super.toMap();
        return {
            ...baseMap,
            'code': code,
            'model': model,
            'category': category.name,
            'length': length.name,
            'color': color,
            'size': size,
            'isAdjustable': isAdjustable,
            'purchasePrice': purchasePrice,
            'rentalPrice': rentalPrice,
            'depositValue': depositValue,
            'sellingPrice': sellingPrice,
            'timesRented': timesRented,
            'lastRentedAt': lastRentedAt?.toIso8601String(),
            'currentStatus': currentStatus.name,
            'notes': notes,
            'photos': photos?.map((photo) => base64Encode(photo)).toList(),
        };
    }

    // TODO: Maybe this can be rewritten into returning a actual `TableSchema` object instead of a map
    static Map<String, String> tableFields() {
        final baseSchema = BaseModel.tableFields();
        return {
            ...baseSchema,
            'code': 'STRING',
            'model': 'STRING',
            'category': 'STRING',
            'length': 'STRING',
            'color': 'STRING',
            'size': 'INT64',
            'isAdjustable': 'BOOL',
            'purchasePrice': 'INT64',
            'rentalPrice': 'INT64',
            'depositValue': 'INT64',
            'sellingPrice': 'INT64',
            'timesRented': 'INT64',
            'lastRentedAt': 'STRING',
            'currentStatus': 'STRING',
            'notes': 'STRING',
            'photos': 'BYTES',
        };
    }
}

// TODO: Maybe these enums can have a "fromString" method to avoid the "firstWhere" with the toString comparison
// TODO: Maybe be worth having a sort of "EnumHelper" to centralize and handle enum parsing, since this "fromString" logic is likely to be repeated across multiple models and enums
enum DressCategory {
    party,
    bride,
    bridesmaid,
    prom,
    debutante;

    static const Map<DressCategory, String> displayNames = {
        DressCategory.party: 'Festa',
        DressCategory.bride: 'Noiva',
        DressCategory.bridesmaid: 'Madrinha',
        DressCategory.prom: 'Formatura',
        DressCategory.debutante: 'Debutante',
    };
}

enum DressLength {
    short,
    midi,
    long;

    static const Map<DressLength, String> displayNames = {
        DressLength.short: 'Curto',
        DressLength.midi: 'Médio',
        DressLength.long: 'Longo',
    };
}

enum DressStatus {
    available,
    reserved,
    fitting,
    rented,
    washing,
    adjusting,
    unavailable;

    static const Map<DressStatus, String> displayNames = {
        DressStatus.available: 'Disponível',
        DressStatus.reserved: 'Reservado',
        DressStatus.fitting: 'Prova',
        DressStatus.rented: 'Alugado',
        DressStatus.washing: 'Lavando',
        DressStatus.adjusting: 'Ajustando',
        DressStatus.unavailable: 'Indisponível',
    };
}