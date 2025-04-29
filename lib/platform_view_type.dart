enum PlatformViewType {
  kBasic,
  kInput,
  kInputPureFlutter,
  kAnimatedSurfaceView,
  kHcpp,
  kGen4,
}

String platformViewTypeAsString(PlatformViewType viewType) {
  switch (viewType) {
    case PlatformViewType.kBasic:
      return 'static-text-view';
    case PlatformViewType.kInput:
      return 'input-grid-view';
    case PlatformViewType.kInputPureFlutter:
      return 'input-grid-view-flutter';
    case PlatformViewType.kAnimatedSurfaceView:
      return 'animated-surface-view';
    case PlatformViewType.kHcpp:
      return 'hybrid-composition++';
    case PlatformViewType.kGen4: 
      return 'gen4-platform-view';
  }
}

bool platformViewShouldHaveBanner(PlatformViewType viewType) {
  switch (viewType) {
    case PlatformViewType.kInput:
    case PlatformViewType.kInputPureFlutter:
      return false;
    default:
      return true;
  }
}
