class HabitNotificationConfigModel {
  final bool randomInWindown;
  final bool before5Minutes;

  HabitNotificationConfigModel({
    required this.randomInWindown,
    required this.before5Minutes,
  });

  HabitNotificationConfigModel.defaultConfig()
      : randomInWindown = true,
        before5Minutes = true;

  Map<String, dynamic> toJson() {
    return {
      'randomInWindown': randomInWindown,
      'before5Minutes': before5Minutes,
    };
  }

  factory HabitNotificationConfigModel.fromJson(Map<String, dynamic> json) {
    return HabitNotificationConfigModel(
      randomInWindown: json['randomInWindown'] ?? false,
      before5Minutes: json['before5Minutes'] ?? false,
    );
  }
}
