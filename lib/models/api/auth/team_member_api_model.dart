class TeamMemberApiModel {
  final int userTeamRoleId;
  final int userId;
  final String userName;
  final String mail;
  final String role;
  final bool owner;

  const TeamMemberApiModel({
    required this.userTeamRoleId,
    required this.userId,
    required this.userName,
    required this.mail,
    required this.role,
    required this.owner,
  });

  bool get isAdministrator => role == 'ADMIN';

  String get roleLabel {
    switch (role) {
      case 'ADMIN':
        return 'Administrátor';
      case 'EDITOR':
        return 'Může editovat';
      case 'READER':
        return 'Pouze čtení';
      default:
        return role;
    }
  }

  factory TeamMemberApiModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberApiModel(
      userTeamRoleId: json['userTeamRoleId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String? ?? '',
      mail: json['mail'] as String? ?? '',
      role: json['role'] as String? ?? 'READER',
      owner: json['owner'] as bool? ?? false,
    );
  }
}
