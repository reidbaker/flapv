import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'platform_view_type.dart';
import 'platform_view.dart';

class PlatformViewHolder extends StatefulWidget {
  const PlatformViewHolder({Key? key, required this.viewType})
      : super(key: key);

  final PlatformViewType viewType;

  @override
  State<StatefulWidget> createState() => _PlatformViewHolderState();
}

class _PlatformViewHolderState extends State<PlatformViewHolder> {
  double opacity = 1.0;
  double radius = 0;
  double scale = 1.0;
  double angle = 0;
  bool offstage = false;
  bool banner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(platformViewTypeAsString(widget.viewType)),
      ),
      body: Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: const Color.fromARGB(255, 0, 255, 0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Stack(
              children: <Widget>[
                _HeldPlatformView(
                  angle: -math.pi / 180 * angle,
                  opacity: opacity,
                  radius: radius,
                  scale: scale,
                  viewType: widget.viewType,
                  offstage: offstage,
                ),
                banner
                    ? Opacity(
                        opacity: 0.5,
                        child: Container(
                          constraints: BoxConstraints.expand(
                            height: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .fontSize! *
                                    1.1 +
                                50.0,
                            width: MediaQuery.of(context).size.width / 1.5,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.blue[600],
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(0.2),
                          child: Text('Flutter UI',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white)),
                        ),
                      )
                    : Container(width: 0),
              ],
            )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Opacity'),
                Slider(
                  value: opacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: Colors.greenAccent,
                  label: opacity.toString(),
                  onChanged: (double value) {
                    setState(() {
                      opacity = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rotate'),
                Slider(
                  value: angle,
                  min: 0.0,
                  max: 360.0,
                  divisions: 72,
                  activeColor: Colors.greenAccent,
                  label: angle.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      angle = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Radius'),
                Slider(
                  value: radius,
                  min: 0.0,
                  max: 100.0,
                  divisions: 10,
                  activeColor: Colors.greenAccent,
                  label: radius.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      radius = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Scale'),
                Slider(
                  value: scale,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: Colors.greenAccent,
                  label: scale.toString(),
                  onChanged: (double value) {
                    setState(() {
                      scale = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Offstage'),
                Checkbox(
                  value: offstage,
                  onChanged: (bool? value) {
                    setState(() {
                      offstage = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Overlay banner'),
                Checkbox(
                  value: banner,
                  onChanged: (bool? value) {
                    setState(() {
                      banner = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeldPlatformView extends StatelessWidget {
  const _HeldPlatformView(
      {required this.angle,
      required this.opacity,
      required this.radius,
      required this.scale,
      required this.viewType,
      required this.offstage,
      Key? key})
      : super(key: key);
  final double opacity;
  final double radius;
  final double angle;
  final double scale;
  final PlatformViewType viewType;
  final bool offstage;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: const Color.fromARGB(255, 255, 0, 0))),
        child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Offstage(
                          offstage: offstage,
                          child: PlatformView(viewType: viewType))),
                ),
              ),
            )));
  }
}
