class User {
  final String id;
  final String email;
  final String username;
  final String phone;
  final String primarySos;
  final String userType;
  User({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.primarySos,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      username: json['username'],
      phone: json['phno'],
      primarySos: json['primary_sos'],
      userType: json['userType'],
    );
  }
}
