# Keep TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep GPU delegate
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep Flutter plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep BLE
-keep class com.pauldemarco.flutter_blue.** { *; }

# Keep speech & TTS
-keep class com.google.android.gms.** { *; }
-keep class android.speech.** { *; }