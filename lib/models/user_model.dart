class UserModel {
  final String name;
  final String id;
  final bool writePermission;
  final String mail;

  UserModel(
      {required this.name,
      required this.id,
      required this.writePermission,
      required this.mail,
      });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "writePermission": writePermission,
      "mail": mail,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? '',
      id: json['id'] ?? '',
      writePermission: json['writePermission'] ?? false,
      mail: json["mail"] ?? '',

    );
  }

//

}
