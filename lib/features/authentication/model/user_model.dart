class UserModel {
  final int id;
  final String name;
  final String email;
  final String? apiToken;


  UserModel({required this.id, required this.name, required this.email,required this.apiToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      apiToken: json['token'],
    );
  }
}
