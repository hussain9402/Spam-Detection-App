class ContactModel {
  final String id;
  final String name;
  final String? profileImage;
  final String status;
  final String? email;
  final String? phone;
  final String? address;

  ContactModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.status,
    this.email,
    this.phone,
    this.address,
  });
}

