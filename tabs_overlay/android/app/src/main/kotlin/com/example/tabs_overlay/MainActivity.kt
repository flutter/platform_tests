package com.example.tabs_overlay

import android.content.Context
import android.os.Bundle
import android.util.AttributeSet
import android.view.MotionEvent
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager.widget.ViewPager
import com.google.android.material.tabs.TabLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import java.lang.reflect.Field

class MainActivity : AppCompatActivity() {
    lateinit var flutterEngine: FlutterEngine
    lateinit var flutterView: FlutterView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Run flutter
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault())
        flutterView = findViewById(R.id.flutter_view)
        flutterView.attachToFlutterEngine(flutterEngine)

        val frameLayout : CustomFrameLayout = findViewById(R.id.frame_layout)
        frameLayout.bindFlutterView(flutterView)

        val sectionsPagerAdapter = SectionsPagerAdapter(this, supportFragmentManager)
        val viewPager: ViewPager = findViewById(R.id.view_pager)
        viewPager.adapter = sectionsPagerAdapter
        val tabs: TabLayout = findViewById(R.id.tabs)
        tabs.setupWithViewPager(viewPager)

        try {
            // Remove the touch slop, since in Flutter the slop is only present when
            // there are multiple gesture detectors fighting in the arena.
            //
            // There's no way to configure that neither in Flutter, nor in Android,
            // reflection is the only option.
            val field: Field = viewPager::javaClass.get().getDeclaredField("mTouchSlop")
            field.isAccessible = true
            field.set(viewPager, 0)
        } catch (e: NoSuchFieldException) {
            // It won't work in release mode
            println("mTouch slope reflection failed")
        } catch (e: IllegalAccessException) {
            println("mTouch slope reflection failed")
        }
    }

    override fun onDestroy() {
        flutterEngine.destroy()
        super.onDestroy()
    }

    override fun onPause() {
        super.onPause()
        flutterEngine.lifecycleChannel.appIsInactive()
    }

    override fun onPostResume() {
        super.onPostResume()
        flutterEngine.lifecycleChannel.appIsResumed()
    }

    override fun onBackPressed() {
        flutterEngine.navigationChannel.popRoute()
        super.onBackPressed()
    }

    override fun onStop() {
        flutterEngine.lifecycleChannel.appIsPaused()
        super.onStop()
    }
}

class CustomFrameLayout(context: Context, attrs: AttributeSet?) : FrameLayout(context, attrs) {
    lateinit var flutterView: FlutterView
    fun bindFlutterView(view: FlutterView) {
        flutterView = view
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        flutterView.dispatchTouchEvent(ev)
        return super.dispatchTouchEvent(ev)
    }

}