class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? photoUrl;
  final String phoneNumber; // Add this field

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.phoneNumber, // Required for your chat logic
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber, // Update toJson
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      // Support both 'phoneNumber' or 'phone' keys from Firestore
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '', 
    );
  }
}