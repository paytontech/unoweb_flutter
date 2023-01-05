#!/bin/zsh
echo "Android"
flutter build apk
echo "Android Build Done.\n"
echo "iOS"
flutter build ipa
echo "iOS Build Done.\n"
echo "macOS"
flutter build macos
echo "macOS Build Done.\nWeb"
flutter build web
echo "Web done. All builds finished! View then in build/"