enum CallType {
  incoming,
  outgoing,
  missed,
}

class CallModel {
  final String id;
  final String name;
  final String? profileImage;
  final CallType type;
  final DateTime callTime;
  final bool isGroup;
  final bool isVideoCall;

  CallModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.type,
    required this.callTime,
    this.isGroup = false,
    this.isVideoCall = false,
  });
}

