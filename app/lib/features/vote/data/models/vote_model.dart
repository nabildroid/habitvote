class VoteModel {
  final String id;
  final DateTime openDate;
  final DateTime endDate;
  final DateTime lastUpdate;
  final int up;
  final int down;
  final bool isActivated;
  final String habitId;

  int get total => up + down;

  VoteModel({
    required this.id,
    required this.openDate,
    required this.endDate,
    required this.up,
    required this.down,
    required this.isActivated,
    required this.habitId,
    required this.lastUpdate,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'],
      openDate: DateTime.parse(json['openDate']),
      endDate: DateTime.parse(json['endDate']),
      up: json['up'],
      down: json['down'],
      isActivated: json['isActivated'],
      habitId: json['habitId'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'openDate': openDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'up': up,
      'down': down,
      'isActivated': isActivated,
      'habitId': habitId,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  @override
  String toString() => 'VoteModel(id: $id, habitId: $habitId)';
}
