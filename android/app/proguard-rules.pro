# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep generic signatures and annotations for serialization/deserialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-dontwarn javax.annotation.**

# Play Core and deferred components suppression
-dontwarn com.google.android.play.core.**
