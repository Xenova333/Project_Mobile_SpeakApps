class EventModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? eventDate;
  final String? eventLink;
  final int isMain;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.eventDate,
    this.eventLink,
    this.isMain = 0,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      eventDate: json['event_date'],
      eventLink: json['event_link'],
      isMain: json['is_main'] != null ? int.parse(json['is_main'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'event_date': eventDate,
      'event_link': eventLink,
      'is_main': isMain,
    };
  }
}
