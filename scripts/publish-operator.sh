#! /bin/bash
#
# Creates the Pull Request to https://github.com/operator-framework/community-operators repo
# with the last snyk-operator image version
#
# Input:
# $1 - Operator release version
#
# Output:
# Pull request to https://github.com/operator-framework/community-operators repo
#

set -e

VERSION="$1"
PWD=$(pwd)
CO_UPSTREAM_LOCATION="${PWD}/community-operators"
DEPLOY_LOCATION="${CO_UPSTREAM_LOCATION}/community-operators"
OPERATOR_LOCATION="${PWD}/snyk-operator/deploy/olm-catalog/snyk-operator"

# Configure git user
git config user.email = "runtime@snyk.io"
git config user.name = "Runtime CI/CD"
# TODO: configure some ssh key to verify commit

# Clone Community Operators repo from Snyk
git clone https://github.com/snyk/community-operators.git $CO_UPSTREAM_LOCATION

# Configure upstream
cd $CO_UPSTREAM_LOCATION
git remote add upstream https://github.com/operator-framework/community-operators.git

# Snyk origin with upstream
git fetch upstream
git checkout master
git merge upstream/master

# Copy new release to branch
git checkout -b snyk/snyk-operator
cp -r ${OPERATOR_LOCATION} "${DEPLOY_LOCATION}/"

# Create the singed commit and push
git add "${DEPLOY_LOCATION}/*"
git commit -s -m "Snyk-Operator: release v${VERSION}"
git push --set-upstream origin snyk/snyk-operator

# Create the Pull Request from origin to upstream
# TODO: the Github API call to open the PR. Should we use a node lib?

echo "Pull request open to Community Operators for snyk-operator version ${VERSION}!"