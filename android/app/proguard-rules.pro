# Flutter相关
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart相关
-keep class dart.** { *; }
-keep class **.dart.** { *; }

# Dio
-dontwarn dio.**
-keep class dio.** { *; }
-keep class com.chiptracking.** { *; }

# Provider
-keep class provider.** { *; }

# fl_chart
-keep class fl_chart.** { *; }

# 数据模型
-keep class com.chiptracking.models.** { *; }

# 混淆规则
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Exceptions
