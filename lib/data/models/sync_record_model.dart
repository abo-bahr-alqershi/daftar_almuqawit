// ignore_for_file: public_member_api_docs

class SyncRecordModel {
  final int? id;
  final String entity;
  final String operation;
  final String payloadJson;
  final String? createdAt;
  final String status; // pending | processing | done | failed
  final int retryCount;

  const SyncRecordModel({
    this.id,
    required this.entity,
    required this.operation,
    required this.payloadJson,
    this.createdAt,
    this.status = 'pending',
    this.retryCount = 0,
  });

  SyncRecordModel copyWith({
    int? id,
    String? entity,
    String? operation,
    String? payloadJson,
    String? createdAt,
    String? status,
    int? retryCount,
  }) => SyncRecordModel(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        operation: operation ?? this.operation,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
      );

  factory SyncRecordModel.fromMap(Map<String, Object?> map) => SyncRecordModel(
        id: (map['id'] as num?)?.toInt(),
        entity: map['entity'] as String,
        operation: map['operation'] as String,
        payloadJson: map['payload'] as String,
        createdAt: map['created_at'] as String?,
        status: map['status'] as String? ?? 'pending',
        retryCount: (map['retry_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'entity': entity,
        'operation': operation,
        'payload': payloadJson,
        'created_at': createdAt,
        'status': status,
        'retry_count': retryCount,
      };
}
