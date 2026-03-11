class FootbarConnectState {
  final int userId;
  final String nickname;
  final String favFoot;
  final String favPosition;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String profilePic;
  final String ageCategory;
  final String height;
  final String weight;
  final String strength;
  final String countryFlag;
  final bool active;

  FootbarConnectState({
    required this.userId,
    required this.nickname,
    required this.favFoot,
    required this.favPosition,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.profilePic,
    required this.ageCategory,
    required this.height,
    required this.weight,
    required this.strength,
    required this.countryFlag,
    required this.active,
  });

  factory FootbarConnectState.initial() => FootbarConnectState(
        userId: -1,
        active: false,
        nickname: "",
        favFoot: "",
        favPosition: "",
        firstName: "",
        lastName: "",
        gender: "",
        dateOfBirth: "",
        profilePic: "",
        ageCategory: "",
        height: "",
        weight: "",
        strength: "",
        countryFlag: "",
      );

  FootbarConnectState copyWith({
    int? userId,
    String? nickname,
    String? favFoot,
    String? favPosition,
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    String? profilePic,
    String? ageCategory,
    String? height,
    String? weight,
    String? strength,
    String? countryFlag,
    bool? active,
  }) {
    return FootbarConnectState(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      favFoot: favFoot ?? this.favFoot,
      favPosition: favPosition ?? this.favPosition,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePic: profilePic ?? this.profilePic,
      ageCategory: ageCategory ?? this.ageCategory,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      strength: strength ?? this.strength,
      countryFlag: countryFlag ?? this.countryFlag,
      active: active ?? this.active,
    );
  }
}
