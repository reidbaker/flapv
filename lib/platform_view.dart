import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' show Random;

import 'platform_view_type.dart';

Color randomColor() {
  // ignore: deprecated_member_use
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
  const InputGridViewWidget({super.key});

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
      return const InputGridViewWidget();
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
      return AndroidView2(viewType: platformViewTypeAsString(PlatformViewType.kGen4),);
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

/// Class for discovering if hybrid composition++ mode
/// is supported pior to the creation of a platform view.
/// 
/// Use is optional. 
// Should this be part of HybridAndroidViewController? 
class HcppPlatformViewSupportHandler {
  static Future<bool>? _supportedCheck;
  // Tri-state bool where null indicates it was never set.
  // It is unsafe to set this value to null after being set to non null once.
  static bool? _hcppSupported;

  /// A future value that will complete with true if hcpp 
  /// is supported for the lifetime of this application. 
  /// 
  /// Null supported check indicates determineSupported()
  /// has not been called. 
  static get supportedCheck => _supportedCheck;
  
  /// Cached value that will complete with true if hcpp 
  /// is supported for the lifetime of this application. 
  /// 
  /// Null is returned if support check has an error or the 
  /// value has not been fetched yet. 
  static get hccpSupported => _hcppSupported; 

  static void determineSupported() {
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
}

/// Replacement for [AndroidView]
/// 
/// Seperate widget for 2 reasons
/// 1. To not silently update existing platform views to use 
///    hybrid composistion++ without the devlopers realizing. 
/// 2. To remove the ability for apps to pick which plaform view 
///    strategy is chosen. 
class AndroidView2 extends StatefulWidget {
  const AndroidView2({
     super.key,
    required this.viewType,
    this.onPlatformViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,

  });
  /// The unique identifier for Android view type to be embedded by this widget.
  ///
  /// A [PlatformViewFactory](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html)
  /// for this type must have been registered.
  ///
  /// See also:
  /// TODO(reidbaker): link example. 
  final String viewType;
  
  // TODO(reidbaker): Evaluate if templates are correct still. 
  /// {@template flutter.widgets.AndroidView.onPlatformViewCreated}
  /// Callback to invoke after the platform view has been created.
  ///
  /// May be null.
  /// {@endtemplate}
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// {@template flutter.widgets.AndroidView.hitTestBehavior}
  /// How this widget should behave during hit testing.
  ///
  /// This defaults to [PlatformViewHitTestBehavior.opaque].
  /// {@endtemplate}
  final PlatformViewHitTestBehavior hitTestBehavior;

  /// {@template flutter.widgets.AndroidView.layoutDirection}
  /// The text direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead.
  /// {@endtemplate}
  final TextDirection? layoutDirection;

  @override
  State<AndroidView2> createState() => _AndroidView2State();
}

class _AndroidView2State extends State<AndroidView2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Local copy to avoid mid evaluation cross widget state change.
    bool? localhcppSupportState = HcppPlatformViewSupportHandler.hccpSupported;
    onCreatePlatformView(PlatformViewCreationParams params) {
      debugPrint("onCreatePlatformView: $localhcppSupportState");
      var viewController =
          _createViewContoller(localhcppSupportState ?? false, params.id);
      return viewController
        ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
        ..create();
    }
    if (localhcppSupportState == null) {
    return FutureBuilder(
        future: HcppPlatformViewSupportHandler.supportedCheck,
          builder: (BuildContext context, AsyncSnapshot<bool> supported) {
            if (supported.hasError) {
              debugPrint(
                  'Could not determine hcpp support.');
            } else {
              debugPrint(
                  "checkIfSupported: ${supported.data}, ${supported.connectionState}");
            }
            localhcppSupportState = supported.data;
            if (localhcppSupportState == null) {
              return Container();
            } 
            return PlatformViewLink(
              viewType: widget.viewType,
              surfaceFactory: _createSurfaceFactory,
              onCreatePlatformView: onCreatePlatformView,
            );
          });
    } else {
      debugPrint("checkIfSupported Known: $localhcppSupportState");

      return PlatformViewLink(
        viewType: platformViewTypeAsString(PlatformViewType.kGen4),
        surfaceFactory: _createSurfaceFactory,
        onCreatePlatformView: onCreatePlatformView,
      );
    }
  }

  AndroidViewSurface _createSurfaceFactory(
      BuildContext context, PlatformViewController controller) {
    return AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: widget.hitTestBehavior,
    );
  }

  TextDirection _findLayoutDirection() {
    assert(
        widget.layoutDirection != null || debugCheckHasDirectionality(context));
    return widget.layoutDirection ?? Directionality.of(context);
  }

  AndroidViewController _createViewContoller(bool canUseHcpp, int id) {
    debugPrint('_createViewContoller id= $id, hcpp: $canUseHcpp');
    if (canUseHcpp) {
      var initHybridAndroidView = PlatformViewsService.initHybridAndroidView(
        id: id,
        viewType: widget.viewType,
        layoutDirection: _findLayoutDirection(),
        creationParamsCodec: const StandardMessageCodec(),
      );
      return initHybridAndroidView;
    } else {
      var initSurfaceAndroidView = PlatformViewsService.initSurfaceAndroidView(
        id: id,
            viewType: widget.viewType,
            layoutDirection: _findLayoutDirection(),
        creationParamsCodec: const StandardMessageCodec(),
      );
      return initSurfaceAndroidView;
    }
  }
}
