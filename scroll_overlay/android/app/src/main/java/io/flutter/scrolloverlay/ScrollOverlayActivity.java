package io.flutter.scrolloverlay;

import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;

public class ScrollOverlayActivity extends Activity {
    private static final String TAG = "ScrollOverlayActivity";
    private static final String VELOCITY_CHANNEL = "scroll_overlay.flutter.io/velocity";

    private static final int[] OVERLAY_COLORS = new int[]{0x40ff0000, 0x4000ff00, 0x400000ff};

    private FlutterView flutterView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FlutterMain.ensureInitializationComplete(getApplicationContext(), null);
        setContentView(R.layout.scroll_overlay_layout);

        flutterView = (FlutterView) findViewById(R.id.flutter_view);
        flutterView.runFromBundle(FlutterMain.findAppBundlePath(getApplicationContext()), null);

        ListView overlayList = (ListView) findViewById(R.id.overlay_list);
        overlayList.setAdapter(new OverlayAdapter());

        overlayList.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                flutterView.dispatchTouchEvent(event);
                return false;
            };
        });

        new EventChannel(flutterView, VELOCITY_CHANNEL).setStreamHandler(
            new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventChannel.EventSink events) {
                    // Implement.
                }

                @Override
                public void onCancel(Object arguments) {
                    // Implement.
                }
            }
        );
    }

    @Override
    protected void onDestroy() {
        if (flutterView != null) {
            flutterView.destroy();
        }
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        super.onPause();
        flutterView.onPause();
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        flutterView.onPostResume();
    }

    @Override
    public void onBackPressed() {
        if (flutterView != null) {
            flutterView.popRoute();
            return;
        }
        super.onBackPressed();
    }

    private class OverlayAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            return Integer.MAX_VALUE;
        }

        @Override
        public Object getItem(int position) {
            return position;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                TextView textView = new TextView(ScrollOverlayActivity.this);
                textView.setLayoutParams(new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    (int) TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP,
                        40,
                        getResources().getDisplayMetrics())));
                textView.setTextColor(0xFF000000);
                textView.setGravity(Gravity.CENTER_VERTICAL);
                textView.setTextSize(15);
                textView.setPadding((int) TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP,
                    6,
                    getResources().getDisplayMetrics()), 0, 0, 0);
                convertView = textView;
            }
            int color = OVERLAY_COLORS[position % OVERLAY_COLORS.length];
            convertView.setBackground(new ColorDrawable(color));
            ((TextView) convertView).setText("Android " + position);
            return convertView;
        }
    }
}
