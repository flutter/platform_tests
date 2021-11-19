package io.flutter.scroll_overlay;

import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.EventChannel;

public class ScrollOverlayActivity extends Activity {
    private static final String VELOCITY_CHANNEL = "scroll_overlay.flutter.io/velocity";
    private static final int[] OVERLAY_COLORS = new int[]{0x40ff0000, 0x4000ff00, 0x400000ff};
    private static final String engineId = "engine_id";

    FlutterEngine flutterEngine;

    class VelocityTracker extends RecyclerView.OnScrollListener {
        int currentDy = 0;
        boolean locked = false;
        EventChannel.EventSink velocitySink;

        /**
         * How many times the velocity is measured per second.
         * <p>
         * Setting this to not too small value - to get a meaningful velocity information,
         * and not too big - to distinguish individual digits after thousands.
         */
        static final int measurementsPerSecond = 25;

        final Handler handler = new Handler(Looper.getMainLooper());
        Runnable velocityTrackerRunnable = new Runnable() {
            @Override
            public void run() {
                if (flutterEngine == null) {
                    return;
                }
                if (!locked) {
                    velocitySink.success((double) currentDy * measurementsPerSecond);
                    if (currentDy == 0) {
                        locked = true;
                    }
                    currentDy = 0;
                }
                handler.postDelayed(velocityTrackerRunnable, 1000 / measurementsPerSecond);
            }
        };

        void start(EventChannel.EventSink velocitySink) {
            this.velocitySink = velocitySink;
            velocityTrackerRunnable.run();
        }

        void stop() {
            handler.removeCallbacksAndMessages(null);
            velocitySink = null;
        }

        @Override
        public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
            locked = false;
            currentDy += dy;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.scroll_overlay_layout);

        VelocityTracker velocityTracker = new VelocityTracker();

        // Create flutter view
        flutterEngine = new FlutterEngine(this);
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault());
        FlutterEngineCache
                .getInstance()
                .put(engineId, flutterEngine);
        FlutterView flutterView = findViewById(R.id.flutter_view);
        flutterView.attachToFlutterEngine(flutterEngine);
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VELOCITY_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        velocityTracker.start(events);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        velocityTracker.stop();
                    }
                }
        );

        // Create list
        RecyclerView recyclerView = findViewById(R.id.recycler_view);
        recyclerView.addItemDecoration(new DividerItemDecoration(this, 0)); // Remove divider
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(new OverlayAdapter());
        recyclerView.addOnScrollListener(velocityTracker);

        recyclerView.setOnTouchListener((v, event) -> {
            flutterView.dispatchTouchEvent(event);
            return false;
        });
    }

    @Override
    protected void onDestroy() {
        FlutterEngineCache.getInstance().remove(engineId);
        flutterEngine.destroy();
        flutterEngine = null;
        super.onDestroy();
    }


    @Override
    protected void onPause() {
        super.onPause();
        flutterEngine.getLifecycleChannel().appIsInactive();
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        flutterEngine.getLifecycleChannel().appIsResumed();
    }

    @Override
    public void onBackPressed() {
        flutterEngine.getNavigationChannel().popRoute();
        super.onBackPressed();
    }

    @Override
    protected void onStop() {
        flutterEngine.getLifecycleChannel().appIsPaused();
        super.onStop();
    }

    private class OverlayAdapter extends RecyclerView.Adapter<OverlayAdapter.OverlayViewHolder> {
        @NonNull
        @Override
        public OverlayViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(ScrollOverlayActivity.this);
            View view = inflater.inflate(R.layout.row, parent, false);
            return new OverlayViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull OverlayViewHolder holder, int position) {
            holder.bind(position);
        }

        @Override
        public int getItemCount() {
            return Integer.MAX_VALUE;
        }

        class OverlayViewHolder extends RecyclerView.ViewHolder {
            public OverlayViewHolder(@NonNull View itemView) {
                super(itemView);
            }

            /**
             * The base item extent at 0 index.
             * <p>
             * Each item will have an extent = this + index.
             */
            static final int baseItemExtent = 40;

            void bind(int position) {
                int color = OVERLAY_COLORS[position % OVERLAY_COLORS.length];
                itemView.setBackground(new ColorDrawable(color));
                final int height = (int) TypedValue
                        .applyDimension(TypedValue.COMPLEX_UNIT_DIP, baseItemExtent + position, getResources().getDisplayMetrics());
                itemView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height));
                TextView textView = itemView.findViewById(R.id.text_view);
                textView.setText("Android " + position);
                textView.setTextColor(0xFF000000);
                textView.setGravity(Gravity.CENTER_VERTICAL);
                textView.setTextSize(16);
                textView.setPadding((int) TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP,
                        6,
                        getResources().getDisplayMetrics()), 0, 0, 0);
            }
        }
    }
}
