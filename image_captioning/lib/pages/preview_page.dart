import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import 'package:flutter/services.dart';
import 'package:image_captioning/components/slideAnimation.dart';
import 'package:image_captioning/components/shared_components.dart';
import 'package:image_captioning/model/encoder.dart';
import 'package:image_captioning/model/decoder.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CaptionGenerator extends StatefulWidget {

  const CaptionGenerator({Key? key, required this.imageBytes, this.rotateImage = false}) : super(key: key);

  final Uint8List imageBytes;
  final bool rotateImage;

  @override
  State<CaptionGenerator> createState() => _CaptionGeneratorState();
}

class _CaptionGeneratorState extends State<CaptionGenerator> {

  void _generateCaption() async {
    Encoder encoder = await Encoder.instance;
    Decoder decoder = await Decoder.instance;
    String? caption;


    ByteBuffer? features = await encoder.predict(widget.imageBytes, widget.rotateImage);
    if (features != null) {
      caption = await decoder.predict(features);
    }

    imageLib.Image? img = imageLib.decodeImage(widget.imageBytes);
    Image image = Image.memory(
      widget.imageBytes,
      fit: BoxFit.fitWidth,
      width: img?.width.toDouble(),
      height: img?.height.toDouble(),
    );


    Future.delayed(const Duration(seconds: 1),() {
      if (context.mounted)  {
        Navigator.of(context).pushReplacement(
            SlideAnimation(
                beginX: 1,
                page: PreviewPage(
                  image: image,
                  caption: caption!,
                  rotateImage: widget.rotateImage,
                )
            )
        );
      }
    } );

  }

  @override
  void initState() {
    super.initState();
    _generateCaption();
    // imageLib.Image? img = imageLib.decodeImage(widget.imageBytes);
    // print("${img?.width.toDouble()}x${img?.height.toDouble()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
          child: loader()
        /*LoadingFilling.square(
            borderColor: Colors.teal,
            size: 100,
          )*/
      ),
    );
  }
}



class PreviewPage extends StatelessWidget {

  PreviewPage({Key? key, required this.image, required this.caption, required this.rotateImage}) : super(key: key);

  final Image image;
  final String caption;
  final FlutterTts flutterTts = FlutterTts();
  bool rotateImage;

  _playSound() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);
    await flutterTts.speak(caption);
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]);

    _playSound();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF121212),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Transform.rotate(
                angle: rotateImage ? -pi/2 : 0,
                child: SizedBox(
                  width: double.infinity,
                  child: InnerShadow(
                    shadows: const [
                      Shadow(
                        color: Colors.white,
                        offset: Offset(0, 0),
                        blurRadius: 10,
                      )
                    ],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FittedBox(
                          fit: (image.height! > image.width!)? BoxFit.fitWidth : BoxFit.contain,
                          child: image
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // const Spacer(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.teal, //New
                            blurRadius: 20.0,
                            offset: Offset(0, 0))
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.teal,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )
                      ),
                      child: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.teal, //New
                            blurRadius: 20.0,
                            offset: Offset(0, 0))
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.teal,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )
                      ),
                      child: const Icon(Icons.home_rounded),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ),
              ],
            ),
            // const Spacer(),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white12, //New
                            blurRadius: 25.0,
                            offset: Offset(0, 0))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Center(
                        child: Text(
                          caption,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: "Goldman",
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // const Spacer(),
          ]),
    );
  }
}
