import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:transition_overlay/transition_data_provider.dart';

class TransitionGraph extends StatefulWidget {
  const TransitionGraph({super.key});

  @override
  State<TransitionGraph> createState() => _TransitionGraphState();
}

class _TransitionGraphState extends State<TransitionGraph> {
  double heightDelta = 0;
  double widthDelta = 0;

  @override
  Widget build(BuildContext context) {
    final transitionData = TransitionDataProvider.of(context)!.transitionData;
    final transitionConfiguration =
        TransitionDataProvider.of(context)!.transitionConfiguration;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          heightDelta += details.delta.dy;
          widthDelta -= details.delta.dx;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 120, right: 20),
        child: ColoredBox(
          color: CupertinoColors.systemGrey6.withOpacity(0.9),
          child: ClipRect(
            child: SizedBox(
              width: 220 + widthDelta,
              height: 150 + heightDelta,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AnimatedBuilder(
                          animation: transitionConfiguration,
                          builder: (context, child) {
                            return AnimatedBuilder(
                              animation: transitionData,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(
                                    transitionData.iosData.length.toDouble() *
                                        transitionConfiguration.resolution,
                                    150,
                                  ),
                                  painter: TransitionGraphPainter(
                                    transitionData.iosData,
                                    transitionData.flutterData,
                                    transitionConfiguration.resolution,
                                    transitionConfiguration.frameTime,
                                  ),
                                );
                              },
                            );
                          }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransitionGraphPainter extends CustomPainter {
  TransitionGraphPainter(
    this.iosTransitionData,
    this.flutterTransitionData,
    this.resolution,
    this.frameTime,
  );

  final List<double> iosTransitionData;
  final List<double> flutterTransitionData;
  final double resolution;
  final Duration frameTime;

  @override
  void paint(Canvas canvas, Size size) {
    final longestDataLength =
        max(iosTransitionData.length, flutterTransitionData.length);

    final xPaint = Paint()
      ..color = CupertinoColors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(
        longestDataLength * resolution,
        size.height,
      ),
      xPaint,
    );

    if (longestDataLength != 0) {
      final totalFramesTextPainter = TextPainter(
        text: TextSpan(
          text: "${(frameTime * longestDataLength).inMilliseconds} ms",
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      totalFramesTextPainter.layout();
      totalFramesTextPainter.paint(
        canvas,
        Offset(
          longestDataLength * resolution - totalFramesTextPainter.width,
          size.height,
        ),
      );
    }

    final yPaint = Paint()
      ..color = CupertinoColors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      yPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "1.0",
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      const Offset(2, -8),
    );

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: "0.0",
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(0, size.height),
    );

    // iOS data ---------------------------------------------------------------

    final iosPaint = Paint()
      ..color = CupertinoColors.systemBlue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];

    for (var i = 0; i < iosTransitionData.length; i++) {
      final x = i * resolution;
      final y = size.height - iosTransitionData.elementAt(i) * size.height;

      points.add(Offset(x, y));
    }

    canvas.drawPoints(PointMode.polygon, points, iosPaint);

    // Flutter data -----------------------------------------------------------

    final flutterPaint = Paint()
      ..color = CupertinoColors.systemGreen
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final flutterPoints = <Offset>[];

    for (var i = 0; i < flutterTransitionData.length; i++) {
      final x = i * resolution;
      final y = size.height - flutterTransitionData.elementAt(i) * size.height;

      flutterPoints.add(Offset(x, y));
    }

    canvas.drawPoints(PointMode.polygon, flutterPoints, flutterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
