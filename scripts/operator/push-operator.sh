#! /bin/bash

set -xeo pipefail

CURRENT_DIRECTORY=$1 #$(pwd)
COMMUNITY_FOLDER_LOCATION=$2 # 'community-operators' | 'upstream-community-operators'
COMMUNITY_OPERATORS_UPSTREAM_LOCATION="${CURRENT_DIRECTORY}/community-operators"
DEPLOY_LOCATION="${COMMUNITY_OPERATORS_UPSTREAM_LOCATION}/${COMMUNITY_FOLDER_LOCATION}"
OPERATOR_LOCATION="${CURRENT_DIRECTORY}/snyk-operator/deploy/olm-catalog/snyk-operator"

# Configure git user and gpg key
echo "${OPENSHIFT_OPERATOR_SIGNING_KEY_BASE64}" | base64 -d | gpg --import
git config --global commit.gpgsign true
git config --global user.signingkey "${OPENSHIFT_OPERATOR_SIGNING_KEY_ID}"
git config --global user.email "${OPENSHIFT_OPERATOR_GITHUB_EMAIL}"
git config --global user.name "${OPENSHIFT_OPERATOR_GITHUB_NAME}"

# Clone Community Operators repo from Snyk
git clone https://github.com/snyk/community-operators.git $COMMUNITY_OPERATORS_UPSTREAM_LOCATION
cd "${COMMUNITY_OPERATORS_UPSTREAM_LOCATION}"
git checkout -b snyk/${COMMUNITY_FOLDER_LOCATION}/snyk-operator-v${NEW_OPERATOR_VERSION}

# Create location if it doesn't exist
mkdir -p  "${DEPLOY_LOCATION}/snyk-operator"

# Copy new release to branch
cp -r "${OPERATOR_LOCATION}/${NEW_OPERATOR_VERSION}" "${DEPLOY_LOCATION}/snyk-operator/."
cp "${OPERATOR_LOCATION}/snyk-operator.package.yaml" "${DEPLOY_LOCATION}/snyk-operator/."

# Create the signed commit and push
git add "${DEPLOY_LOCATION}/snyk-operator/*"
git commit -s -m "Upgrade snyk-operator to version ${NEW_OPERATOR_VERSION} on ${COMMUNITY_FOLDER_LOCATION}"
git push --set-upstream origin --force snyk/${COMMUNITY_FOLDER_LOCATION}/snyk-operator-v${NEW_OPERATOR_VERSION}
