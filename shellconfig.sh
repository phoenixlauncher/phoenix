#!/bin/bash
# Description: This file contains the configuration for the shell scripts

##############################################
# Xcode configuration
# APP_VERSION is the version number of the app (This is the only thing you should change, the rest of the file can be left as is unless you want to change the app name or the destination directory for the archive)
APP_VERSION="0.1.0"

# Set the app name and destination directory for the archive
APP_NAME="Phoenix"
ARCHIVE_APP_DIR="$HOME/Desktop/$APP_NAME"_v"$APP_VERSION"

# For the free developer account, the signing certificate is "Apple Development," so if you change to a paid apple developer account, you have to change the grep string to something else
SIGNING_CERTIFICATE=$(security find-identity -v -p codesigning | grep "Apple Development" | awk '{print $2}')
TEAM_ID=$(security find-identity -v -p codesigning | grep "Apple Development" | awk -F'[()]' '{print $3}')

EXPORT_OPTIONS_PLIST="exportOptions.plist"

##############################################
# Github configuration for generate_appcast.sh
GITHUB_USER="phoenixlauncher"
RELEASE_FILE_EXTENSION="dmg"

##############################################
# Sparkle config
# Directory to generate the appcast.xml file to
APPCAST_DIR=$(pwd) # This is the current directory

# Gets the path of the generate_appcast binary which is in ~/Library/Developer/Xcode/DerivedData/sparkletest-fqkskzevuwuhmcfjetohllfhqzis/SourcePackages/artifacts/sparkle/bin (the stuff after sparkletest- is a random string)
SPARKLE_BIN_DIR=$(find ~/Library/Developer/Xcode/DerivedData -name generate_appcast -type f -print0 | awk -F/ '{for(i=1;i<=NF;i++){if($i == "bin"){for(j=1;j<=i;j++){printf("%s/",$j)};break}};print ""}')

# For version specific release notes
SPARKLE_RELEASE_NOTES_LINK="https://github.com/$GITHUB_USER/$APP_NAME/releases/tag/v$APP_VERSION"

# For full release notes
SPARKLE_FULL_RELEASE_NOTES_LINK="https://github.com/$GITHUB_USER/$APP_NAME/releases"