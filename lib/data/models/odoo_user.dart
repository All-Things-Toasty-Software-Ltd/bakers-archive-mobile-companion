/// Authenticated Odoo user profile and session.
class OdooUser {
  final int uid;
  final String name;
  final String username;
  final String database;
  final String serverUrl;
  final String? sessionId;
  final bool isAdmin;
  final bool isInternalUser;
  final String? avatarUrl;

  const OdooUser({
    required this.uid,
    required this.name,
    required this.username,
    required this.database,
    required this.serverUrl,
    this.sessionId,
    this.isAdmin = false,
    this.isInternalUser = false,
    this.avatarUrl,
  });

  factory OdooUser.fromJson(Map<String, dynamic> json) {
    return OdooUser(
      uid: json['uid'] as int? ?? 0,
      name: json['name'] as String? ?? 'Odoo User',
      username: json['username'] as String? ?? '',
      database: json['database'] as String? ?? '',
      serverUrl: json['server_url'] as String? ?? '',
      sessionId: json['session_id'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isInternalUser: json['is_internal_user'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'database': database,
      'server_url': serverUrl,
      'session_id': sessionId,
      'is_admin': isAdmin,
      'is_internal_user': isInternalUser,
      'avatar_url': avatarUrl,
    };
  }
}
