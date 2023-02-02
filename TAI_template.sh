#!/bin/bash -e
##
## Soure customizations
. $(dirname ${0})/liberty_settings.sh

WLP_SERVER_NAME=${1}
test -z "${WLP_SERVER_NAME}"        && {
                        echo "no server name provided ..."
                        exit 1
                        }


WLP_SERVER_DIR=${WLP_USER_DIR}/servers/${WLP_SERVER_NAME}
mkdir -p ${TAI_RESOURCE_DIR}

# CONFIGURATION OVERRIDE file to define TAI prerequs
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/tai_prereqs.xml
<server description="TAI prereqs">
    <featureManager>
        <feature>appSecurity-4.0</feature>
    </featureManager>

    <library id="customTAILib" name="customTAILib" description="Shared library for custom TAI">
        <fileset dir="${shared.resource.dir}/libs/tai" includes="zepta-tai-interceptor-1.0.4.jar zepta-tai-utils-1.0.4.jar bcprov-jdk15on-1.51.jar"></fileset>
    </library>

    <!-- Use pattern to load! (can upgrade only all at the same time :( ))
        <library id="customTAILib" name="customTAILib" description="Shared library for custom TAI">
            <fileset dir="${shared.resource.dir}/libs/tai" includes="zepta-tai-*.jar bcprov-jdk15on-1.51.jar"></fileset>
        </library>
    -->
</server>
EOM

# CONFIGURATION OVERRIDE file to define TAIs
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/tai_definitions.xml
<server description="TAI settings">
    <trustAssociation id="customTai" initializeAtFirstRequest="false"
    	invokeForUnprotectedURI="false" failOverToAppAuthType="false"
    	continueAfterUnprotectedURI="false" disableLtpaCookie="false">

    	<interceptors
    		id="PVAExternePartnerTAI" className="at.sozvers.pva.infra.tai.PVAExternePartnerTAI"
    		invokeAfterSSO="true" invokeBeforeSSO="false" libraryRef="customTAILib">
    		<properties
                pvaLoginUrl="http://portalpva.pva.sozvers.at/pvalogin"
                pvaType="COOKIE"
                pvaTaiDebug="false"
                pvaExpireTime="60000"
                pvaParam="USER"
                pvaRegEx="^[0][2][0-9a-zA-Z]{6}$"
                pvaPrefix="PVA"
                pvaPublicKey="${shared.resource.dir}/security/public_key.pem">
            </properties>
    	</interceptors>

    	<interceptors
    		id="SVATAI" className="at.sozvers.pva.infra.tai.SVATAI"
    		invokeAfterSSO="true" invokeBeforeSSO="false" libraryRef="customTAILib">
    		<properties
                pvaLoginUrl="http://svawebst.sva.sozvers.at/zepta/"
                pvaType="COOKIE"
                pvaTaiDebug="false"
                pvaExpireTime="60000"
                pvaParam="USER"
                pvaRegEx="^[4][0][0-9a-zA-Z]{2,8}$"
                pvaPrefix="SVA"
                pvaPublicKey="${shared.resource.dir}/security/sva_test_public_key.pem">
            </properties>
        </interceptors>

    	<interceptors
    		id="SVBTAI" className="at.sozvers.pva.infra.tai.SVBTAI"
    		invokeAfterSSO="true" invokeBeforeSSO="false" libraryRef="customTAILib">
    		<properties
                pvaLoginUrl="http://svbi.svb.sozvers.at/"
                pvaType="COOKIE"
                pvaTaiDebug="false"
                pvaExpireTime="60000"
                pvaParam="USER"
                pvaRegEx="^[5][0][0-9a-zA-Z]{4}$"
                pvaPrefix="SVA"
                pvaPublicKey="${shared.resource.dir}/security/svb_test_public_key.pem">
            </properties>
    	</interceptors>
    </trustAssociation>
</server>
EOM
