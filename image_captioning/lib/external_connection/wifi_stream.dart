import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' as ui;
import 'dart:async';

import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:image_captioning/slideAnimation.dart';
import 'package:image_captioning/external_connection/esp_wifi.dart';
import 'package:image_captioning/preview_page.dart';


class WifiStream extends StatefulWidget {
  final WebSocketChannel channel;

  const WifiStream({Key? key, required this.channel}) : super(key: key);

  @override
  WifiStreamState createState() => WifiStreamState();
}

class WifiStreamState extends State<WifiStream> {
  double newVideoSizeWidth = 640;
  double newVideoSizeHeight = 480;

  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.grey[900],
          child: StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const WifiCheck()));
                });
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              } else {
                return Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "ESP-32 CAM \nLive Feed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                          fontFamily: "Goldman"
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 270,
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: GestureZoomBox(
                          maxScale: 5.0,
                          doubleTapScale: 2.0,
                          duration: const Duration(milliseconds: 200),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.memory(
                              snapshot.data,
                              gaplessPlayback: true,
                              width: newVideoSizeWidth,
                              height: newVideoSizeHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: const BoxDecoration(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                          color: Colors.black),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: IconButton(
                                  onPressed: takeScreenShot,
                                  iconSize: 50,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.circle, color: Colors.white),
                                )
                            ),
                          ]
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
    );
  }

  takeScreenShot() async {
    final RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    // Image img = Image.memory(
    //   pngBytes!,
    //   fit: BoxFit.fitWidth,
    //   width: image.width.toDouble(),
    //   height: image.height.toDouble(),
    // );

    if (mounted) {
      Navigator.of(context)
        .push(SlideAnimation(beginX: 1, page: CaptionGenerator(imageBytes: pngBytes)));
    }

  }


}