class TaskModel {
  final String date;
  final bool wokeUpEarly;
  final bool learnedDsa;
  final String note;

  TaskModel({
    required this.date,
    required this.wokeUpEarly,
    required this.learnedDsa,
    required this.note,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      date: json['date'],
      wokeUpEarly: json['wokeUpEarly'],
      learnedDsa: json['learnedDsa'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'wokeUpEarly': wokeUpEarly,
    'learnedDsa': learnedDsa,
    'note': note,
  };
}
