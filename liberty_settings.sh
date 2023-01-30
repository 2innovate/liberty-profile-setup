# ================================================================================
# Customize here as required

export WLP_VERSION=22.0.0.12
export WLP_EDITION=wlp-base-all
export WLP_JDK_VERSION=jdk-17.0.5+8

export WLP_BIN_ROOT=/opt/liberty
export WLP_LOG_ROOT=/opt/liberty/logs
export WLP_PROFILE_ROOT=/opt/liberty/profiles
export WLP_JAVA_ROOT=/opt/liberty/java

export WLP_BIN_USER=${LIBERTY_BIN_USER:=liberty}
export WLP_BIN_USER_UID=4242
export WLP_BIN_GROUP=${LIBERTY_BIN_GROUP:=liberty}
export WLP_BIN_GROUP_GID=4242
export WLP_DEV_USER=${LIBERTY_DEV_USER:=libdev}
export WLP_DEV_USER_UID=4243
export WLP_DEV_GROUP=${LIBERTY_DEV_GROUP:=libdev}
export WLP_DEV_GROUP_GID=423
export WLP_DEPLOY_GROUP=${LIBERTY_DEPLOY_GROUP:=libdeploy}
export WLP_DEPLOY_GROUP_GID=4244

WLP_BASE_PORT_HTTP=9080
WLP_BASE_PORT_HTTPS=9443

#
# ================================================================================
#

export WLP_BIN_DIR=${WLP_BIN_ROOT}/${WLP_EDITION}-${WLP_VERSION}
export WLP_SERVER_CMD_PATH=${WLP_BIN_DIR}/wlp/bin
export WLP_SERVER_CMD=${WLP_SERVER_CMD_PATH}/server


export JAVA_HOME=$WLP_JAVA_ROOT/$WLP_JDK_VERSION

# use a single profile-dir 'wlp' for multiple JVMs (servers)
export WLP_PROFILE_NAME=wlp
export WLP_USER_DIR=$WLP_PROFILE_ROOT/$WLP_PROFILE_NAME
export WLP_OUTPUT_DIR=$WLP_LOG_ROOT/$WLP_PROFILE_NAME

# for AES encrypred secrets
WLP_AES_KEY_FILE_NAME=aesKey.properties
WLP_AES_KEY_FILE=${WLP_USER_DIR}/shared/resources/security/$WLP_AES_KEY_FILE_NAME

#
# ================================================================================
#
JAVA_URL="https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.5%2B8_openj9-0.35.0/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz"
LIBERTY_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/22.0.0.12/openliberty-22.0.0.12.zip"
