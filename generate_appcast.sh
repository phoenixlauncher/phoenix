#!/bin/bash
# Description: Generates the appcast.xml file for Sparkle

source shellconfig.sh

sh create_dmg.sh

$SPARKLE_BIN_DIR/generate_appcast $ARCHIVE_APP_DIR

# Go to $ARCHIVE_APP_DIR and run the following command to replace the enclosure url with the correct one
cd $ARCHIVE_APP_DIR

# Edit the appcast.xml file to replace the enclosure url with the correct one
sed -i '' "s|https://$GITHUB_USER.github.io/$APP_NAME/$APP_NAME.$RELEASE_FILE_EXTENSION|https://github.com/$GITHUB_USER/$APP_NAME/releases/download/v$APP_VERSION/$APP_NAME.$RELEASE_FILE_EXTENSION|g" appcast.xml

# Add the release notes link and the full release notes link to the appcast.xml file
sed -i '' "s|</item>|<sparkle:releaseNotesLink>$SPARKLE_RELEASE_NOTES_LINK</sparkle:releaseNotesLink>\n<sparkle:fullReleaseNotesLink>$SPARKLE_FULL_RELEASE_NOTES_LINK</sparkle:fullReleaseNotesLink>\n</item>|g" appcast.xml

# Copy the appcast.xml file to the APPCAST_DIR
cp appcast.xml $APPCAST_DIR