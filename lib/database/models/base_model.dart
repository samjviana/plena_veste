abstract class BaseModel {
    String uuid;
    DateTime createdAt;
    DateTime updatedAt;

    BaseModel({
        required this.uuid,
        required this.createdAt,
        required this.updatedAt,
    });

    Map<String, dynamic> toMap() {
        return {
            'uuid': uuid,
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': updatedAt.toIso8601String(),
        };
    }

    static Map<String, String> tableFields() {
        return {
            'uuid': 'STRING',
            'createdAt': 'TIMESTAMP',
            'updatedAt': 'TIMESTAMP',
        };
    }
}
