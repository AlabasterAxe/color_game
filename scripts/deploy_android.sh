set -e

flutter build appbundle -t lib/main.dart release

cd android

bundler exec fastlane android beta
