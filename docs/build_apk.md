# Building an APK

1. Open a terminal in the project directory.
2. (Optional) Run:
   ```
   flutter clean
   ```
3. Build the release APK:
   ```
   flutter build apk
   ```
4. Find your APK at:
   build/app/outputs/flutter-apk/app-release.apk

*For split APKs per CPU architecture, run:*
   ```
   flutter build apk --split-per-abi
   ```
