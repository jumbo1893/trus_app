class UserModel {
  final String name;
  final String id;
  final bool isOnline;
  final String mail;

  UserModel(
      {required this.name,
      required this.id,
      required this.isOnline,
      required this.mail,
      });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "isOnline": isOnline,
      "mail": mail,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? '',
      id: json['id'] ?? '',
      isOnline: json['isOnline'] ?? false,
      mail: json["mail"] ?? '',

    );
  }

//

}
