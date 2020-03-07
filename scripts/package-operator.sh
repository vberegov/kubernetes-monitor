#! /bin/bash
#
# Inputs:
# - $1: A semantic version (e.g. "1.2.3") which will be used to set the Operator version
# - $2: An OCI image tag for the Operator image (e.g. "discardable-1234" or "1.2.3")
# - $3: An OCI image tag for the snyk-monitor image (e.g. "discardable-1234" or "1.2.3")
#
# Outputs:
# - Creates a new directory under snyk-operator/deploy/olm-catalog/snyk-operator with the version provided as input $1
# - Updates snyk-operator.package.yaml to point to the new version that was provided as input $1
# - Updates the ClusterServiceVersion with inputs $1, $2, and $3 to populate the right versions for the Operator, Operator image tag, and snyk-monitor image tag respectively
#
# Packages a new version of the Operator using the Operator template files in this repository.
# The template files should have been previously generated by using the operator-sdk.
#
# This produces files ready to be tested and then published to OperatorHub to release
# a new version of the Snyk monitor (and accompanying Operator).
#

set -e

NEW_OPERATOR_VERSION="$1"
NEW_OPERATOR_IMAGE_TAG="$2"
NEW_MONITOR_IMAGE_TAG="$3"

CSV_LOCATION="./snyk-operator/deploy/olm-catalog/snyk-operator"
OPERATOR_PACKAGE_YALM_LOCATION="${CSV_LOCATION}/snyk-operator.package.yaml"
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cp -r "${CSV_LOCATION}/0.0.0" "${CSV_LOCATION}/${NEW_OPERATOR_VERSION}"

sed -i.bak "s|0.0.0|${NEW_OPERATOR_VERSION}|g" "${OPERATOR_PACKAGE_YALM_LOCATION}"
rm "${OPERATOR_PACKAGE_YALM_LOCATION}.bak"

SOURCE_CSV="${CSV_LOCATION}/${NEW_OPERATOR_VERSION}/snyk-operator.v0.0.0.clusterserviceversion.yaml"
TARGET_CSV="${CSV_LOCATION}/${NEW_OPERATOR_VERSION}/snyk-operator.v${NEW_OPERATOR_VERSION}.clusterserviceversion.yaml"
mv "${SOURCE_CSV}" "${TARGET_CSV}"

sed -i.bak "s|0.0.0|${NEW_OPERATOR_VERSION}|g" "${TARGET_CSV}"
sed -i.bak "s|TIMESTAMP_OVERRIDE|${CURRENT_TIMESTAMP}|g" "${TARGET_CSV}"
sed -i.bak "s|SNYK_OPERATOR_VERSION_OVERRIDE|${NEW_OPERATOR_VERSION}|g" "${TARGET_CSV}"
sed -i.bak "s|SNYK_OPERATOR_IMAGE_TAG_OVERRIDE|${NEW_OPERATOR_IMAGE_TAG}|g" "${TARGET_CSV}"
sed -i.bak "s|SNYK_MONITOR_IMAGE_TAG_OVERRIDE|${NEW_MONITOR_IMAGE_TAG}|g" "${TARGET_CSV}"
rm "${TARGET_CSV}.bak"

echo "Operator version: ${NEW_OPERATOR_VERSION}"
echo "Operator image tag: ${NEW_OPERATOR_IMAGE_TAG}"
echo "snyk-monitor image tag: ${NEW_MONITOR_IMAGE_TAG}"