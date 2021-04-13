set -e

flutter build ios --release --no-codesign -t lib/main.dart

cd ios

bundler exec fastlane ios beta