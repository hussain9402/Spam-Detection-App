import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallService {
  static  String appId = dotenv.env['AGORA_APP_ID'] ?? '';

  late RtcEngine engine;

  Future<RtcEngine> init({
    required String channelName,
    required bool isVideo,
  }) async {
    await [
      Permission.microphone,
      if (isVideo) Permission.camera,
    ].request();

    engine = createAgoraRtcEngine();

    await engine.initialize(
       RtcEngineContext(appId: appId),
    );

    if (isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.disableVideo();
    }

    await engine.joinChannel(
  token: "",
  channelId: channelName,
  uid: 0,
  options: const ChannelMediaOptions(),
);


    return engine;
  }

  Future<void> dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }
}
