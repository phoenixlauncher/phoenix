#!/bin/bash
# Description: Archive the app with Xcode and export it to the ARCHIVE_APP_DIR directory listed in shellconfig.sh. (Change app version from shellconfig.sh to the desired version number.)

source shellconfig.sh

echo "Starting to archive $APP_NAME to $ARCHIVE_APP_DIR"

# Clean the build directory
echo "Running xcodebuild clean..."

xcodebuild clean -project $APP_NAME/$APP_NAME.xcodeproj -scheme $APP_NAME

# Change the version number in project.pbxproj using sed instead of agvtool because it doesn't work for xcode 13+ properly
# Don't want to use fastlane either because its another dependency
# Change the fields, CURRENT_PROJECT_VERSION and MARKETING_VERSION

# Change the directory to the project directory
cd $APP_NAME/$APP_NAME.xcodeproj/
# Search and edit the project.pbxproj file for the appropriate fields with regex
sed -i '' -e 's/CURRENT_PROJECT_VERSION = [0-9]*.[0-9]*.[0-9]*;/CURRENT_PROJECT_VERSION = '$APP_VERSION';/g' project.pbxproj
sed -i '' -e 's/MARKETING_VERSION = [0-9]*.[0-9]*.[0-9]*;/MARKETING_VERSION = '$APP_VERSION';/g' project.pbxproj
# Change the directory back to the parent directory
cd ..

# Archive the app with Xcode
xcodebuild archive -project $APP_NAME.xcodeproj -scheme $APP_NAME -configuration Release -derivedDataPath build -archivePath build/$APP_NAME.xcarchive

# Edit the exportOptions.plist file
cat >$EXPORT_OPTIONS_PLIST <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>$SIGNING_CERTIFICATE</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
</dict>
</plist>
EOF

# Export the archive to the destination directory with the exportOptions.plist file
xcodebuild -exportArchive -archivePath build/$APP_NAME.xcarchive -exportPath $ARCHIVE_APP_DIR -exportOptionsPlist $EXPORT_OPTIONS_PLIST