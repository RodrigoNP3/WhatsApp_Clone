class CallModel {
  final String callerId;
  final String callerName;
  final String callerPic;
  final String recieverId;
  final String recieverName;
  final String recieverPic;
  final String callId;
  final bool hasDialled;

  CallModel({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.recieverId,
    required this.recieverName,
    required this.recieverPic,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'recieverId': recieverId,
      'recieverName': recieverName,
      'recieverPic': recieverPic,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    //
    return CallModel(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPic: map['callerPic'] ?? '',
      recieverId: map['recieverId'] ?? '',
      recieverName: map['recieverName'] ?? '',
      recieverPic: map['recieverPic'] ?? '',
      callId: map['callId'] ?? '',
      hasDialled: map['hasDialled'] ?? false,
    );
  }
}
