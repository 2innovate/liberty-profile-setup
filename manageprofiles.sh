#!/bin/bash -eu

##
## Soure customizations
. $(dirname ${0})/liberty_settings.sh


#
# ================================================================================
# FUNCTIONS

function createDir {
    local DIR=${1}
    test -z "$DIR" && echo "ERROR: directory '$DIR' is missing" && exit 101
    test -d "$DIR" || mkdir -p "$DIR"
}

function usage(){
    cat <<EOT

    $0 <command> <options>

      command:  list, create, run, status, status-all

      - list                    zeigt alle definierten Liberty Server an
      - create NAME [OFFSET]    legt einen neuen Liberty Server mit Namen und Port ${WLP_BASE_PORT_HTTP} + OFFSET (std: 0) an
      - systemd NAME            erstellt ein --user systemd service für server NAME
      - delete NAME [-f]        loescht den genannten Liberty Server (inkl Logs). '-f ' loescht ohne nach zu fragen!
      - run    NAME             starten den Liberty Server im Vordergrund. Strg-C um abzubrechen!
      - status NAME             zeigt den Serverstatus eines Servers an
      - status-all              zeigt den Serverstatus aller Liberty Server an

EOT
}

function createSystemdService {
    local __server=${1}

    test -z "${__server}" && echo "ERROR: An die Funktion ${0} wurde keine Servername übergeben" && exit 107

    __servers=$($WLP_SERVER_CMD list | sed -ne '/^The following servers are defined/,$p' | tail -n+3)
    echo ${__servers} | grep ${__server} 2>1 >/dev/null || {
        echo "ERROR: Servername \"${__server}\" existiert nicht in diesem Profil!"
        exit 107
    }
    ##
    ## Enable user-space systemctl to start at boot timt
    loginctl enable-linger $(id -un)
    touch ~/.bashrc
    grep XDG_RUNTIME_DIR ~/.bashrc 2>/dev/null || echo 'export XDG_RUNTIME_DIR=/run/user/$(id -u)' >> ~/.bashrc
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    ##
    ## Copy systemd file
    mkdir -p ~/.config/systemd/user
    cp bin/liberty@.service ~/.config/systemd/user || {
        echo "ERROR: Failed to copy liberty@.service to /etc/systemd/system"
        exit 107
    }
    sed -i  '/User=/d' ~/.config/systemd/user/liberty@.service
    sed -i  '/Group=/d' ~/.config/systemd/user/liberty@.service
    systemctl --user daemon-reload
    systemctl --user status liberty@${__server}

    echo "systemctl service liberty@${__server} installed"
}
#
# ================================================================================
# ================================================================================
#   MAIN
# ================================================================================
# Checks
test ! -d "$JAVA_HOME"      && echo -e "ERROR: Java Home existiert nicht: '$JAVA_HOME'" && exit 1
test ! -d "$WLP_BIN_DIR"    && echo -e "ERROR: Liberty Verzeichnis existiert nicht: '$WLP_BIN_DIR'" && exit 1
test ! -f "$WLP_SERVER_CMD" && echo -e "ERROR: Liberty Server Command nicht gefunden: '$WLP_SERVER_CMD'" && exit 1


# CMD LINE ARG CHECK
ACTION=${1:---help}   ## lowercase transform
ACTION=${ACTION,,}   ## lowercase transform



if [ "${ACTION}" = "create" ]; then

    WLP_SERVER_NAME=${2?ERROR: Arg1: Kein SERVERNAME angegeben.}
    WLP_SERVER_DIR=$WLP_USER_DIR/servers/$WLP_SERVER_NAME

    WLP_PORT_OFFSET=${3:-0}
    if [[ ! "${WLP_PORT_OFFSET}" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Ungültiger Port Offset: $WLP_PORT_OFFSET "
        exit 3
    fi

    # createDir "${WLP_USER_DIR}"
    createDir "${WLP_USER_DIR}/shared/apps"
    createDir "${WLP_USER_DIR}/shared/config"
    createDir "${WLP_USER_DIR}/shared/resources/security"

    # create a new shared AES symmetric encryption key - if it does not exist:
    if [ ! -f "$WLP_AES_KEY_FILE" ]; then
        echo "wlp.password.encryption.key=$(openssl rand -hex 64)" > $WLP_AES_KEY_FILE
    fi

    if [ -d "$WLP_SERVER_DIR" ]; then
            echo "ERROR: Server $WLP_SERVER_NAME existiert bereits!"
            exit 1
    fi

    cat << EOM

    Erzeuge Liberty Server: $WLP_PROFILE_NAME/$WLP_SERVER_NAME

            Server.Root:  $WLP_SERVER_DIR
            Log.Root   :  $WLP_OUTPUT_DIR/$WLP_SERVER_NAME
            Web.Ports  :  $((WLP_BASE_PORT_HTTP + WLP_PORT_OFFSET)) / $((WLP_BASE_PORT_HTTPS + WLP_PORT_OFFSET))

            server.cmd  :  $WLP_SERVER_CMD

EOM
    # create the Liberty server
    $WLP_SERVER_CMD create $WLP_SERVER_NAME

    # check / create a few server specific directories
    createDir "${WLP_SERVER_DIR}/configDropins/overrides"
    createDir "${WLP_SERVER_DIR}/configDropins/defaults"

    # encode the default keystore password
    ### => generate a new one, eg. using `openssl rand -hex 24`
    echo -e "\n**********\nWARNING: using default WLP_KEYSTORE_PASS !\n**********\n"
    WLP_KEYSTORE_PASS="4f482105ff00a20b3826c2983479928a4c64c8d548327284"
    WLP_KEYSTORE_PASS_ENC=$(${WLP_SERVER_CMD_PATH}/securityUtility encode --encoding=aes --key="$(cut -d= -f2- ${WLP_AES_KEY_FILE})" ${WLP_KEYSTORE_PASS})

    ### create SERVER.ENV
    cat << EOM | sed -e 's/^\s*//' > ${WLP_SERVER_DIR}/server.env
        WLP_BIN_DIR=${WLP_BIN_DIR}
        WLP_USER_DIR=${WLP_USER_DIR}
        WLP_OUTPUT_DIR=${WLP_OUTPUT_DIR}
        JAVA_HOME=${JAVA_HOME}
EOM

    ### create JVM.options with log rotation
    cat << EOM | sed -e 's/^\s*//' > ${WLP_SERVER_DIR}/jvm.options
        -verbose:gc
        -Xverbosegclog:logs/verbosegc.log.%X,5,50000
EOM

    ### create BOOTSTRAP.properties
    cat << EOM | sed -e 's/^\s*//' > ${WLP_SERVER_DIR}/bootstrap.properties
        wlp.port.http      = $((WLP_BASE_PORT_HTTP + WLP_PORT_OFFSET))
        wlp.port.https     = $((WLP_BASE_PORT_HTTPS + WLP_PORT_OFFSET))
        # wlp.port.offset = ${WLP_PORT_OFFSET}

        wlp.keystore.pass       = ${WLP_KEYSTORE_PASS_ENC}

        # include AES symmetric key from shared resource dir (relative to the server directory):
        bootstrap.include       = ../../shared/resources/security/${WLP_AES_KEY_FILE_NAME}
EOM

    # MAIN server.xml
    cat << "EOM" > ${WLP_SERVER_DIR}/server.xml
    <server description="main server config. Will be merged with /configDropins/**/">
        <featureManager>
            <feature>jakartaee-9.1</feature>
            <feature>monitor-1.0</feature>
            <feature>mpMetrics-4.0</feature>
        </featureManager>

        <!-- Automatically expand WAR files and EAR files -->
        <applicationManager autoExpand="true"/>

        <!-- HTTP Endpoints -->
        <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="${wlp.port.http}" httpsPort="${wlp.port.https}" >
            <sslOptions></sslOptions>
            <httpOptions></httpOptions>
            <accessLogging enabled="false"
                maxFileSize="100" maxFiles="3"
                rolloverStartTime="00:00" rolloverInterval="1d"
                filePath="${server.output.dir}/logs/http_access.log"
                logFormat='%h %u %{t}W "%r" %s %b %D' >
            </accessLogging>
        </httpEndpoint>

        <!-- Disable security for metrics -->
        <mpMetrics authentication="false"/>
    </server>
EOM

    # MASTER CONFIGURATION OVERRIDE file server.xml
    cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/server.xml
    <server description="configDropins server.xml - provide secure defaults for Liberty">
        <featureManager>
            <feature>transportSecurity-1.0</feature>
        </featureManager>

        <keyStore id="defaultKeyStore"
            location="${shared.resource.dir}/security/${wlp.server.name}-key.p12"
            type="PKCS12"
            password="${wlp.keystore.pass}" />

        <keyStore id="defaultTrustStore"
            location="${shared.resource.dir}/security/${wlp.server.name}-trust.p12"
            type="PKCS12"
            password="${wlp.keystore.pass}" />

        <!-- TLS configuration for Inbound SSL connection-->
        <ssl id="defaultSSLConfig" keyStoreRef="defaultKeyStore" trustStoreRef="defaultTrustStore" />

        <!-- LOGGING -->
        <logging logDirectory="${server.output.dir}/logs"
            maxFileSize="100" maxFiles="10"
            rolloverStartTime="00:00" rolloverInterval="1d">
            messageFormat="SIMPLE" isoDateFormat="true"
        </logging>
    </server>
EOM

    # CONFIGURATION OVERRIDE file admin-center
    cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/admin-center.xml
    <server description="configDropin admin-center">
        <featureManager>
            <feature>adminCenter-1.0</feature>
            <feature>websocket-2.0</feature>
            <feature>appSecurity-4.0</feature>
        </featureManager>

        <basicRegistry id="basic" realm="BasicRealm">
            <user name="admin" password="admin"/>
        </basicRegistry>

        <administrator-role>
            <user>admin</user>
        </administrator-role>

        <remoteFileAccess>
            <readDir>${server.config.dir}</readDir>
            <!-- <writeDir>${server.config.dir}</writeDir> -->
        </remoteFileAccess>
    </server>
EOM


    #
    # Keystores
    #
    # Generate self signed TLS certificate & key in P12 keytstore
    ${JAVA_HOME}/bin/keytool -genkeypair  -keyalg RSA -keysize 4096 -sigalg SHA256withRSA  -alias "${WLP_SERVER_NAME}" -keystore "${WLP_USER_DIR}/shared/resources/security/${WLP_SERVER_NAME}-key.p12" -dname "CN=${WLP_SERVER_NAME}-$(hostname)" -validity 3650 -storepass ${WLP_KEYSTORE_PASS} -storetype PKCS12
    #
    # Export cert to be imported wherever needed
    ${JAVA_HOME}/bin/keytool -exportcert -alias "${WLP_SERVER_NAME}" -keystore "${WLP_USER_DIR}/shared/resources/security/${WLP_SERVER_NAME}-key.p12" -file "/tmp/${WLP_SERVER_NAME}.cer" -storepass ${WLP_KEYSTORE_PASS} -storetype PKCS12
    #
    # Create server specific trust store and import own certificate
    ${JAVA_HOME}/bin/keytool -importcert -keystore "${WLP_USER_DIR}/shared/resources/security/${WLP_SERVER_NAME}-trust.p12" -storepass ${WLP_KEYSTORE_PASS} -alias "${WLP_SERVER_NAME}" -file /tmp/${WLP_SERVER_NAME}.cer -storetype PKCS12  -noprompt


elif [ "${ACTION}" = "delete" ]; then
    WLP_SERVER_NAME=${2?ERROR: Arg1: Kein SERVERNAME angegeben.}
    CONFIRM=${3:-yes}
    WLP_SERVER_DIR=$WLP_USER_DIR/servers/$WLP_SERVER_NAME
    if [ ! -d "$WLP_SERVER_DIR" ]; then
        echo "ERROR: DELETE: Das Server-Root Verzeichnis '$WLP_SERVER_DIR' existiert nicht!"
        exit 2
    fi
    if [ "${CONFIRM,,}" != "-f" ]; then
        echo -e "\nPress any key to delete '$WLP_SERVER_DIR' now, or Ctrl-C to abort ..."
        read key
    fi
    rm -rf "${WLP_SERVER_DIR}" "${WLP_OUTPUT_DIR}/${WLP_SERVER_NAME}" "${WLP_USER_DIR}/shared/resources/security/${WLP_SERVER_NAME}-key.p12"
    rm -rf "${WLP_SERVER_DIR}" "${WLP_OUTPUT_DIR}/${WLP_SERVER_NAME}" "${WLP_USER_DIR}/shared/resources/security/${WLP_SERVER_NAME}-trust.p12"
    echo -e "Server '${WLP_SERVER_DIR}' wurde gelöscht.\n"


elif [[ "${ACTION}" =~ ^run|^status$ ]]; then
    WLP_SERVER_NAME=${2?ERROR: Arg1: Kein SERVERNAME angegeben.}
    WLP_SERVER_DIR=$WLP_USER_DIR/servers/$WLP_SERVER_NAME
    $WLP_SERVER_CMD $ACTION $WLP_SERVER_NAME

elif [[ "${ACTION}" == "systemd" ]]; then
    WLP_SERVER_NAME=${2?ERROR: Arg1: Kein SERVERNAME angegeben.}
    createSystemdService "${WLP_SERVER_NAME}"

elif [[ "${ACTION}" = "status-all" ]]; then
    servers=$($WLP_SERVER_CMD list | sed -ne '/^The following servers are defined/,$p' | tail -n+3)
    # echo "Found: $servers"
    for server in $servers; do
        $WLP_SERVER_CMD status $server
    done


elif [[ "${ACTION}" =~ ^list|^help$ ]]; then
    $WLP_SERVER_CMD $ACTION


elif [[ "${ACTION}" =~ ^-+h(elp)?$ ]]; then
    usage

else
    echo -e "ERROR: Unbekanntes COMMAND: $ACTION\n"
    usage
fi
