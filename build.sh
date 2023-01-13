#!/bin/bash

# only run the following code if the first argument is not '-s'
if [[ "$1" != "-s" ]]; then
echo "Building Android"
flutter build apk
cd /Users/paytondev/Documents/GitHub/unoweb_flutter/build/app/outputs/flutter-apk
mv app-release.apk justone.apk
echo "Android build done\nBuilding iOS"
flutter build ipa
echo "iOS build done\nBuilding & zipping macOS"
flutter build macos
cd /Users/paytondev/Documents/GitHub/unoweb_flutter/build/macos/Build/Products
zip -r macOS.zip release
echo "macOS build done\nLast but probably least, building Web"
flutter build web
fi
echo "All builds done; deploying web version"
cd /Users/paytondev/Documents/GitHub/paytontech.github.io/
git pull
cd /Users/paytondev/Documents/GitHub/unoweb_flutter
cp -f -R build/web/* /Users/paytondev/Documents/GitHub/paytontech.github.io/
cd /Users/paytondev/Documents/GitHub/paytontech.github.io/
git commit -a -m "update"
git push
echo "Deployed to web; Deploying iOS"
cd /Users/paytondev/Documents/GitHub/unoweb_flutter/build/ios/ipa
fastlane pilot upload --skip-submission --api_key_path keys.json --ipa 'justone.ipa'

if [["$1" != '-r']] then
echo "iOS deploy done\nNow for the GitHub release:\n"
cd /Users/paytondev/Documents/GitHub/unoweb_flutter/
set -e
function strip {
    local STRING=${1#$"$2"}
    echo ${STRING%$"$2"}
}
file=$(cat pubspec.yaml)

BUILD_NAME=$(echo $file | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p')

BUILD_NUMBER=$(git rev-list HEAD --count)
BUILD_NAME=$(strip "$BUILD_NAME" "+")
echo "Creating release under tag \"$BUILD_NAME\""
gh release create $BUILD_NAME '/Users/paytondev/Documents/GitHub/unoweb_flutter/build/ios/ipa/justone.ipa' '/Users/paytondev/Documents/GitHub/unoweb_flutter/build/macos/Build/Products/macOS.zip' '/Users/paytondev/Documents/GitHub/unoweb_flutter/build/app/outputs/flutter-apk/justone.apk'  --latest
fi