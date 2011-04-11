#!/bin/sh

#  AdHocDeployment.sh
#  Newsgroup
#
#  Created by Jim Kubicek on 4/1/11.
#  Copyright 2011 jimkubicek.com. All rights reserved.

#  Update version number
agvtool next-version -all
agvtool new-marketing-version 1.1.2

#  Update commit
VERS=`agvtool vers -terse`
MVERS=`agvtool what-marketing-version -terse1`
TAG="v$MVERS-$VERS"
COMMIT_MSG="Update version to v$MVERS ($VERS)"

# Update settings.bundle
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:3:DefaultValue 'v$MVERS ($VERS)'" Resources/Settings.bundle/Root.plist

git add .
git commit -m "$COMMIT_MSG"

#  Git tag
git tag $TAG -m "$COMMIT_MSG"

#  Build and Archive


#  Push to TestFlightApp