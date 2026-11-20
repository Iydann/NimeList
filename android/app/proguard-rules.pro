# Keep Google Sign-In & Android Credential Manager classes during R8 release shrinking
-keep class com.google.android.libraries.identity.googleid.** { *; }
-keep class androidx.credentials.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.android.gms.auth.**
