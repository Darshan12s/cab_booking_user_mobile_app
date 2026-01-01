# Proguard rules for Razorpay and other dependencies
# Keep proguard.annotation.Keep and KeepClassMembers
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep Razorpay classes (if using Razorpay)
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Add any additional keep rules from missing_rules.txt below
# Added from missing_rules.txt
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
