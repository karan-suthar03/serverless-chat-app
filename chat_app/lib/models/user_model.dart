class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? profilePictureUrl;
  final String status;
  final DateTime? lastSeen;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePictureUrl,
    required this.status,
    this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
      status: json['status']?.toString() ?? 'Offline',
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'status': status,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? profilePictureUrl,
    String? status,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.displayName == displayName &&
        other.profilePictureUrl == profilePictureUrl &&
        other.status == status &&
        other.lastSeen == lastSeen;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      displayName,
      profilePictureUrl,
      status,
      lastSeen,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, displayName: $displayName, status: $status)';
  }
}