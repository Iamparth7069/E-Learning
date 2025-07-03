class UserModelClass {
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? role;

  UserModelClass({this.userId, this.firstName, this.lastName, this.email, this.role});

  factory UserModelClass.fromJson(Map<String, dynamic> json) {
    return UserModelClass(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }
}
