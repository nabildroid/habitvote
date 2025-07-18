class VoteModel {
  final String id;
  final DateTime lastUpdate;
  final DateTime createdAt;
  final int up;
  final int down;
  final String habitId;

  int get total => up + down;

  VoteModel({
    required this.id,
    required this.up,
    required this.down,
    required this.habitId,
    required this.lastUpdate,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'],
      up: json['up'] ?? 0,
      down: json['down'] ?? 0,
      habitId: json['habitId'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'up': up,
      'down': down,
      'createdAt': createdAt.toIso8601String(),
      'habitId': habitId,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  @override
  String toString() => 'VoteModel(id: $id, habitId: $habitId)';
}
