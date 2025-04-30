import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' show Random;

import 'platform_view_type.dart';

Color randomColor() {
  return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
}

class InputGridCellWidget extends StatefulWidget {
  const InputGridCellWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputGridCellWidgetState();
}

class _InputGridCellWidgetState extends State<InputGridCellWidget> {
  Color color = randomColor();

  _changeColor() {
    setState(() {
      color = randomColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerUp: (PointerUpEvent e) => _changeColor(),
        child: Container(
            color: color, width: 90, height: 90, child: const Text('X')));
  }
}

class InputGridViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Column(children: [
        InputGridCellWidget(),
        InputGridCellWidget(),
        InputGridCellWidget()
      ]),
      Column(children: [
        InputGridCellWidget(),
        InputGridCellWidget(),
        InputGridCellWidget()
      ]),
      Column(children: [
        InputGridCellWidget(),
        InputGridCellWidget(),
        InputGridCellWidget()
      ]),
    ]);
  }
}

class PlatformView extends StatelessWidget {
  const PlatformView({Key? key, required this.viewType}) : super(key: key);
  final PlatformViewType viewType;

  Widget createChild(
      PlatformViewType viewType, Map<String, dynamic> creationParams) {
    if (viewType == PlatformViewType.kInputPureFlutter) {
      return InputGridViewWidget();
    }
    if (viewType == PlatformViewType.kHcpp) {
      return PlatformViewLink(
        viewType: platformViewTypeAsString(viewType),
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.translucent,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initHybridAndroidView(
            id: params.id,
            viewType: platformViewTypeAsString(viewType),
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    }
    if (viewType == PlatformViewType.kGen4) {
      return Gen4PlatformViewWidget();
    }
    return AndroidView(
      viewType: platformViewTypeAsString(viewType),
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Texture Layer Hybrid composition
        return Container(
            decoration: BoxDecoration(border: Border.all(width: 1)),
            child: createChild(viewType, creationParams));
      default:
        throw UnsupportedError(
            'Unsupported TargetPlatform: $defaultTargetPlatform');
    }
  }
}

class Gen4PlatformViewWidget extends StatefulWidget {
  const Gen4PlatformViewWidget({
    super.key,
  });
  @override
  State<Gen4PlatformViewWidget> createState() => _Gen4PlatformViewWidgetState();
}

class _Gen4PlatformViewWidgetState extends State<Gen4PlatformViewWidget> {
  late final Future<bool> _supportedCheck;
  late final Future<String> _calculation;

  @override
  void initState() {
    super.initState();
    _supportedCheck = HybridAndroidViewController.checkIfSupported();
    _calculation = Future<String>.delayed(
      const Duration(seconds: 1),
      () => 'Data Loaded',
    );
    debugPrint('init state called');
    _supportedCheck.then((value) => debugPrint('success: $value'),
        onError: (error) => debugPrint('Error: $error'));
    // Future<bool>.delayed(
    //   const Duration(seconds: 2),
    //   () {
    //     debugPrint('Supported called');
    //     return HybridAndroidViewController.checkIfSupported();
    //   },
    // ).then((value) => debugPrint('success: $value'), onError: (error) => debugPrint('Error: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _supportedCheck,
        builder: (BuildContext context, AsyncSnapshot<bool> supported) {
          return FutureBuilder(
              future: _calculation,
              builder: (BuildContext context, AsyncSnapshot<String> calc) {
                debugPrint('Calc: ${calc.data}');
                if (supported.hasError) {
                  debugPrint('Could not determine hcpp support');
                }
                debugPrint(
                    "checkIfSupported: ${supported.data}, ${supported.connectionState}");
            return PlatformViewLink(
                  viewType: platformViewTypeAsString(PlatformViewType.kGen4),
              surfaceFactory:
                  (BuildContext context, PlatformViewController controller) {
                return AndroidViewSurface(
                  controller: controller as AndroidViewController,
                  gestureRecognizers: const <Factory<
                      OneSequenceGestureRecognizer>>{},
                  hitTestBehavior: PlatformViewHitTestBehavior.translucent,
                );
              },
              onCreatePlatformView: (PlatformViewCreationParams params) {
                if (supported.data == true) {
                  return PlatformViewsService.initHybridAndroidView(
                    id: params.id,
                        viewType:
                            platformViewTypeAsString(PlatformViewType.kGen4),
                    layoutDirection: TextDirection.ltr,
                    creationParamsCodec: const StandardMessageCodec(),
                  )
                    ..addOnPlatformViewCreatedListener(
                        params.onPlatformViewCreated)
                    ..create();
                } else {
                  return PlatformViewsService.initSurfaceAndroidView(
                    id: params.id,
                        viewType:
                            platformViewTypeAsString(PlatformViewType.kGen4),
                        layoutDirection: TextDirection.ltr,
                    creationParamsCodec: const StandardMessageCodec(),
                  )
                    ..addOnPlatformViewCreatedListener(
                        params.onPlatformViewCreated)
                    ..create();
                }
              },
            );
          });
        });
  }
}
