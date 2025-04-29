package com.example.flapv;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.platform.PlatformViewRegistry;

public class MainActivity extends FlutterActivity {
  @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
      final PlatformViewRegistry registry = flutterEngine.getPlatformViewsController().getRegistry();
      registry.registerViewFactory("static-text-view", new StaticTextViewFactory());
      registry.registerViewFactory("input-grid-view", new InputGridViewFactory());
      registry.registerViewFactory("animated-surface-view", new AnimatedSurfaceViewFactory());
      registry.registerViewFactory("hybrid-composition++", new AnimatedSurfaceViewFactory());
      registry.registerViewFactory("gen4-platform-view", new StaticTextViewFactory());
    }
}
