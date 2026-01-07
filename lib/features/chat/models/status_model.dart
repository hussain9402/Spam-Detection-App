class StatusModel {
  final String id;
  final String name;
  final String? profileImage;
  final bool isMyStatus;

  StatusModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.isMyStatus = false,
  });
}

