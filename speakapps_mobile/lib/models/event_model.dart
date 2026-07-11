class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? image;
  final String? eventDate;
  final String? eventLink;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.eventDate,
    this.eventLink,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      image: json['image'],
      eventDate: json['event_date'],
      eventLink: json['event_link'],
      createdBy: int.tryParse(json['created_by']?.toString() ?? ''),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
