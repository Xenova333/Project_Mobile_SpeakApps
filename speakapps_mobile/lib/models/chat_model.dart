class ChatModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final int? replyToId;
  final bool isRead;
  final String createdAt;
  final String? friendName;
  final String? friendProfilePic;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.replyToId,
    required this.isRead,
    required this.createdAt,
    this.friendName,
    this.friendProfilePic,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      receiverId: int.tryParse(json['receiver_id'].toString()) ?? 0,
      message: json['message'] ?? '',
      replyToId: json['reply_to_id'] != null ? int.tryParse(json['reply_to_id'].toString()) : null,
      isRead: json['is_read'] == 1 || json['is_read'] == '1' || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
      friendName: json['friend_name'],
      friendProfilePic: json['friend_profile_pic'],
    );
  }
}
