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
  static Future<bool>? _supportedCheck;
  // Tri-state bool where null indicates it was never set.
  // It is unsafe to set this value to null after being set to non null once.
  static bool? _hcppSupported;

  @override
  void initState() {
    super.initState();
    // If we have not calculated hcpp support and no other class has
    // started checking for the support then kick off the async work
    // and save the result.
    if (_hcppSupported == null && _supportedCheck == null) {
      _supportedCheck = () async {
        return _hcppSupported =
            await HybridAndroidViewController.checkIfSupported();
      }();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local copy to avoid mid evaluation state change.
    final bool? localhcppSupportState = _hcppSupported;
    // TODO bias towards hcpp if api level is high enough and impeller is enabled.
    // Possibly using ApplicationInfo ai = getPackageManager().getApplicationInfo(this.getPackageName(), PackageManager.GET_META_DATA);
    // a non false value would indicate impeller enabled.
    if (localhcppSupportState == null) {
    return FutureBuilder(
        future: _supportedCheck,
          builder: (BuildContext context, AsyncSnapshot<bool> supported) {
            if (supported.hasError) {
              debugPrint(
                  'Could not determine hcpp support assuming unsupported.');
            } else {
              debugPrint(
                  "checkIfSupported: ${supported.data}, ${supported.connectionState}");
            }
            return _createPvWithKnownSupport(supported.data ?? false);
          });
    } else {
      debugPrint("checkIfSupported Known: $localhcppSupportState");
      return _createPvWithKnownSupport(localhcppSupportState);
    }
  }

  /// Helper method to abstract away the source of hcpp support.
  PlatformViewLink _createPvWithKnownSupport(bool canUseHcpp) {
    return PlatformViewLink(
      viewType: platformViewTypeAsString(PlatformViewType.kGen4),
      surfaceFactory: _createSurfaceFactory,
      onCreatePlatformView: (PlatformViewCreationParams params) {
        var viewController = _createViewContoller(canUseHcpp, params.id);
        return viewController
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  AndroidViewSurface _createSurfaceFactory(
      BuildContext context, PlatformViewController controller) {
    return AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.translucent,
    );
  }

  AndroidViewController _createViewContoller(bool canUseHcpp, int id) {
    if (canUseHcpp) {
      var initHybridAndroidView = PlatformViewsService.initHybridAndroidView(
        id: id,
        viewType: platformViewTypeAsString(PlatformViewType.kGen4),
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
      );
      return initHybridAndroidView;
    } else {
      var initSurfaceAndroidView = PlatformViewsService.initSurfaceAndroidView(
        id: id,
            viewType: platformViewTypeAsString(PlatformViewType.kGen4),
            layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
      );
      return initSurfaceAndroidView;
    }
  }
}
