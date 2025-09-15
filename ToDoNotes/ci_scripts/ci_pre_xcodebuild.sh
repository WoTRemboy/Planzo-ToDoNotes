#!/bin/sh

#  ci_pre_xcodebuild.sh
#  ToDoNotes
#
#  Created by Roman Tverdokhleb on 15/09/2025.
#  


echo "Stage: PRE-Xcode Build is activated .... "

# Move to the place where the scripts are located.
# This is important because the position of the subsequently mentioned files depend of this origin.
cd $CI_PRIMARY_REPOSITORY_PATH/ci_scripts || exit 1

# Write a JSON File containing all the environment variables and secrets.
printf "{\"GOOGLE_CLIENT_ID\":\"%s\",\"GOOGLE_URL_SCHEME\":\"%s\"}" "$GOOGLE_CLIENT_ID" "$GOOGLE_URL_SCHEME" >> ../ToDoNotes/SupportingFiles/Secrets.json

echo "Wrote Secrets.json file."

echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
