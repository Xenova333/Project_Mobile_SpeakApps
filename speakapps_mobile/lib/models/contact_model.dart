class ContactModel {
  final int id;
  final int userId;
  final int friendId;
  final String status;
  final String createdAt;
  final String? name;
  final String? profilePic;
  final String? nim;
  final String? semester;
  final String? gender;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  ContactModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.name,
    this.profilePic,
    this.nim,
    this.semester,
    this.gender,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      friendId: int.tryParse(json['friend_id'].toString()) ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      name: json['name'],
      profilePic: json['profile_pic'],
      nim: json['nim']?.toString(),
      semester: json['semester']?.toString(),
      gender: json['gender']?.toString(),
      lastMessage: json['latest_message'],
      lastMessageTime: json['latest_chat_time'],
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
    );
  }
}
