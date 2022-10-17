import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_flutter_ui/common/utils/utils.dart';
import 'package:whatsapp_flutter_ui/common/widgets/loader.dart';
import 'package:whatsapp_flutter_ui/config/agora_config.dart';
import 'package:whatsapp_flutter_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_flutter_ui/models/call_model.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final CallModel call;
  final bool isGroupChat;
  const CallScreen({
    super.key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;

  @override
  void initState() {
    super.initState();

    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: AppConstants.baseUrl,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.call.recieverName),
      ),
      body: client == null
          ? const Loader()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(client: client!),
                  AgoraVideoButtons(
                    client: client!,
                    disconnectButtonChild: IconButton(
                        onPressed: () async {
                          await client!.engine.leaveChannel();
                          // ignore: use_build_context_synchronously
                          ref.read(callControllerProvider).endCall(
                                context,
                                widget.call.callerId,
                                widget.call.recieverId,
                              );
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.call_end)),
                  ),
                ],
              ),
            ),
    );
  }
}
