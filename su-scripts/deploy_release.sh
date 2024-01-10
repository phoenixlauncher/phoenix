#!/bin/bash
# Description: This script is used to deploy a new release to GitHub. It will create a new tag, push the new appcast.xml file, and create a new release on GitHub. It will also upload the archive to the release.

source shellconfig.sh
source .env

sh generate_appcast.sh
echo "Finished generating appcast.xml"

# Export GITHUB_TOKEN from .env for use by github-release cli (Generate a PAT token from Github user settings)
export GITHUB_TOKEN=$GITHUB_TOKEN

# Sync tags from remote repository before creating a new tag
echo "Syncing tags from remote repository before potentially making a new tag..."
git fetch --prune --prune-tags

echo "Checking if tag v$APP_VERSION already exists..."
# Check if the tag already exists
if git rev-parse "v$APP_VERSION" >/dev/null 2>&1; then
    echo "Tag v$APP_VERSION already exists. Please change the APP_VERSION in shellconfig.sh or delete the already existing release from Github to continue. Exiting program..."
    exit 1
fi
echo "Tag v$APP_VERSION does not exist, proceeding..."

echo "Pushing new appcast.xml to GitHub..."
# Commit the changes to the appcast.xml file and push to GitHub
git add appcast.xml
git commit -m "Update appcast.xml to v$APP_VERSION - deploy_release.sh"
git push

# Create a new tag for the release and push it to GitHub
echo "Creating a new tag v$APP_VERSION..."
git tag v$APP_VERSION && git push --tags

echo "Creating a new release of $APP_NAME v$APP_VERSION on GitHub..."

# Create a new release on GitHub
github-release --verbose release \
    --user $GITHUB_USER \
    --repo $APP_NAME \
    --tag v$APP_VERSION \
    --name "v$APP_VERSION" \
    --description "Release v$APP_VERSION. This is an automatic release created by the deploy_release.sh script. Check back later for updated release notes."

# Delete local tags to avoid conflicts from remote repository tags (AFTER CREATING RELEASE)
# If you prune right before creating the release, the tag will not be attached to the release
echo "Syncing tags from remote repository before uploading..."
git fetch --prune --prune-tags

# Wait for the tag to be created on GitHub before uploading the archive to the release
# If the tag does not exist after 60 seconds, exit the program
start_time=$(date +%s)
while true; do
    if github-release info -u $GITHUB_USER -r $APP_NAME | grep -q "v$APP_VERSION"; then
        echo "Tag v$APP_VERSION exists, proceeding with uploading $APP_NAME.$RELEASE_FILE_EXTENSION to the release..."
        break
    fi
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -gt 60 ]; then
        echo "Tag v$APP_VERSION does not exist after waiting $elapsed_time seconds, exiting program..."
        echo "The file $APP_NAME.$RELEASE_FILE_EXTENSION failed to upload to the v$APP_VERSION release."
        echo "Please check your Github repository and delete the v$APP_VERSION release (only contains source code zip and tarball) from Github and try again."
        exit 1
    fi
    echo "Tag v$APP_VERSION does not exist, waiting 5 additional seconds (waited $elapsed_time seconds so far)"
    sleep 5
done

echo "Uploading $APP_NAME.$RELEASE_FILE_EXTENSION to the v$APP_VERSION release..."
# Upload the archive to the release
github-release upload \
    --user $GITHUB_USER \
    --repo $APP_NAME \
    --tag v$APP_VERSION \
    --name "$APP_NAME.$RELEASE_FILE_EXTENSION" \
    --file "$ARCHIVE_APP_DIR/$APP_NAME.$RELEASE_FILE_EXTENSION"

echo "Success! Release v$APP_VERSION has been deployed to GitHub."