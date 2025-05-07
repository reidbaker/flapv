package com.example.flapv;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import android.view.View;
import android.widget.TextView;
import android.graphics.PorterDuff;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import java.util.Random;
import android.view.SurfaceView;
import android.view.ViewGroup;
import android.view.SurfaceHolder;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;
import android.widget.LinearLayout;
import android.widget.FrameLayout;

class AnimationThread extends Thread {
  private TestSurfaceView view;
  private boolean running = false;

  AnimationThread(TestSurfaceView view) {
    this.view = view;
  }

  void setRunning(boolean run) {
    this.running = run;
  }

  @Override
  public void run() {
    while (running) {
      Canvas c = null;
      try {
        c = view.getHolder().lockHardwareCanvas();
        synchronized (view.getHolder()) {
          view.x += 1;
          if (view.x + 100 > view.getWidth()) {
            view.x = 0;
          }
          if (c != null) {
            view.onDraw(c);
          }
        }
      } finally {
        if (c != null) {
          view.getHolder().unlockCanvasAndPost(c);
        }
      }
    }
  }
}

class TestSurfaceView extends SurfaceView {
  private final String TAG = "TestSurfaceView";
  private SurfaceHolder holder;
  private AnimationThread thread;
  float x = 0;
  float y = 0;
  TestSurfaceView(Context context) {
    super(context);
    setWillNotDraw(false);
    thread = new AnimationThread(this);
    holder = getHolder();
    holder.setFormat(PixelFormat.TRANSLUCENT);
    holder.setFixedSize(300, 300);
    holder.addCallback(new SurfaceHolder.Callback() {
      @Override
      public void surfaceDestroyed(SurfaceHolder holder) {
        boolean retry = true;
        thread.setRunning(false);
        while (retry) {
          try {
            thread.join();
            retry = false;
          } catch (InterruptedException e) {

          }
        }
        Log.e(TAG, "surfaceDestroyed");
      }

      @Override
      public void surfaceCreated(SurfaceHolder holder) {
        thread.setRunning(true);
        thread.start();
        Log.e(TAG, "surfaceCreated");
      }

      @Override
      public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.e(TAG, "surfaceChanged width=" + width + " height=" + height);
      }
    });
  }

  @Override
  protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
    final Paint redPaint = new Paint();
    redPaint.setARGB(255, 255, 0, 0);
    canvas.drawRect(x,y, x+100, y+100, redPaint);
  }
}

class AnimatedSurfaceView implements PlatformView {
  private final String TAG = "AnimatedSurfaceView";
  private final ViewGroup rootView;
  private final TextView textView;
  private final TestSurfaceView surfaceView;
  private int id;

  AnimatedSurfaceView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
    this.id = id;
    rootView = new FrameLayout(context);
    surfaceView = new TestSurfaceView(context);
    surfaceView.setOnTouchListener(new View.OnTouchListener() {
      @Override
      public boolean onTouch(View v, MotionEvent event) {
        Log.e(TAG, "#onTouch " + event.getAction());
        return true;
      }
    });
    // TODO add input text box.
    textView = new TextView(context);
    textView.setTextSize(20);
    textView.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);
    textView.setTextColor(Color.BLUE);
    textView.setText("AnimatedSurfaceView");
    rootView.addView(textView);
    // Workaround to avoid being put into a virtual display backend.
    // After a delay, add the surfaceView to the viewGroup.
    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
      public void run() {
        rootView.addView(surfaceView);
      }
    }, 1000);
  }

  @NonNull
  @Override
  public View getView() {
    return rootView;
  }

  @Override
  public void onFlutterViewAttached(@NonNull View flutterView) {
    Log.e(TAG, "#AnimatedSurfaceView#onFlutterViewAttached, " + flutterView);
  }

  @Override
  public void onFlutterViewDetached() {
    Log.e(TAG, "#AnimatedSurfaceView#onFlutterViewDetached");
  }

  @Override
  public void dispose() {
    Log.e(TAG, "#AnimatedSurfaceView#dispose~~ id=" + id);
  }
}

class AnimatedSurfaceViewFactory extends PlatformViewFactory {
  AnimatedSurfaceViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    final Map<String, Object> creationParams = (Map<String, Object>) args;
    return new AnimatedSurfaceView(context, id, creationParams);
  }
}
