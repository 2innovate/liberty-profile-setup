#!/bin/bash -eu

##
## Soure customizations
. $(dirname ${0})/liberty_settings.sh

##
## Globals
CONFIRM=
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

      command:  harden, prereqs

      - harden                  setzt Gruppenberechtigungen und die Berechtigungen am Filesystem
      - prereqs [-f]            erstellt die pre-requisites am Server. -f forces removal of existing $WLP_BIN_ROOT
      - systemd NAME            erstellen systemctl service for server NAME (requires root)

EOT
}

##
## Add user $1 to supplementary group $2
function addUserToSupGroup {
    local __user=${1}
    local __group=${2}

    test -z "${__group}" && echo "ERROR: An die Funktion ${0} wurde keine zusätzliche Gruppe übergeben" && exit 102
    test -z "${__user}" && echo "ERROR: An die Funktion ${0} wurde keine Benutzername übergeben" && exit 102

    if id -nGz "${__user}" 2>1 > /dev/null| grep -qzxF "${__group}" ; then
        echo User \`${__user}\' ist bereits Mitglied der Gruppe \`${__group}\'
    else
        usermod -a -G ${__group} ${__user} 2>1 > /dev/null || {
            echo "ERROR: Benutzer ${__user} konnte nicht zur Gruppe ${__group} hinzugefügt werden"
            exit 102
        }
        echo "Benutzer ${__user} wurde der Gruppe ${__group} hinzugefügt ..."
    fi
}

##
## Create group $1 if it does not exist
function createGroup {
    local __group=${1}
    local __gid=${2}
    test -z "${__gid}" && echo "ERROR: An die Funktion ${0} wurde keine Gruppennummer übergeben" && exit 103
    test -z "${__group}" && echo "ERROR: An die Funktion ${0} wurde kein Gruppenname übergeben" && exit 103

    if getent group ${__group} 2>1 > /dev/null ; then
        echo "Gruppe \"${__group}\" existiert bereits ..."
    else
        groupadd -g ${__gid} ${__group} || {
            echo "ERROR: Fehler beim Erstellen der Gruppe ${__group}"
            exit 103
        }
        echo "Gruppe \"${__group}\" mit gid ${__gid} wurde erstellt ..."
    fi
}

##
## Add user $1 with primary group $2
function createUserWithPrimaryGroup {
    local __user=${1}
    local __uid=${2}
    local __group=${3}

    test -z "${__group}" && echo "ERROR: An die Funktion ${0} wurde keine primäre Gruppe übergeben" && exit 104
    test -z "${__uid}" && echo "ERROR: An die Funktion ${0} wurde keine uid übergeben" && exit 104
    test -z "${__user}" && echo "ERROR: An die Funktion ${0} wurde keine Benutzername übergeben" && exit 104

    if id ${__user} 2>1 > /dev/null ; then
      echo "Benutzer \"${__user}\" existiert bereits. Setze primäre Gruppe auf \"${__group}\" ..."
      usermod -g ${__group} ${__user} 2>1 > /dev/null || {
        echo "ERROR: Fehler beim Einstellen der primären Gruppe für Benutzer \"${__user}\" ..."
        exit 104
      }
    else
        useradd -m -u ${__uid} -g ${__group} ${__user} 2>1 > /dev/null || {
        echo "ERROR: Fehler beim Erstellen des Benutzer \"${__user}\" mit der primären Gruppe \"${__group}\""
        exit 104
        }
        echo "Benutzer \"${__user}\" mit uid ${__uid} und der primären Gruppe \"${__group}\" wurde erstellt ..."
    fi
}


##
## sets the mode for a filesystem object
function setMode {
    local __fsObject=${1}
    local __mode=${2}
    local __filemode

    if [[ $# -eq 3 ]] ; then
        __filemode=${3}
    else
        __filemode=""
    fi

    test -z "${__mode}" && echo "ERROR: An die Funktion ${0} wurde file mode übergeben" && exit 105
    test -z "${__fsObject}" && echo "ERROR: An die Funktion ${0} wurde keine fsObject übergeben" && exit 105

    test -e "${__fsObject}" || {
        echo "ERROR: fsObject \"${__fsObject}\" existiert nicht"
        exit 105
    }

    chmod "${__mode}" "${__fsObject}"
    if test -d "${__fsObject}" ; then
        cd "${__fsObject}"
        find . -type d ! -perm "${__mode}" -exec chmod "${__mode}" {} \;
        ##
        ## If we have a filemode for the files in the directory
        if [[ "${__filemode}." != "." ]] ; then
            echo "Setting filemode \"${__filemode}\" on \"${__fsObject}\" ..."
            find . -type f ! -perm "${__filemode}" -exec chmod "${__filemode}" {} \;
        fi
    fi

    echo "Mode \"${__mode}\" set on \"${__fsObject}\" recursively ..."

}

##
## sets the directory owner for a directory tree or for the file itself
function setOwner {
    local __user=${1}
    local __group=${2}
    local __fsObject=${3}
    local __recurseDirs
    if [[ $# -eq 4 ]] ; then
        __recurseDirs=${4}
    else
        __recurseDirs="false"
    fi
    local __recursively=""

    test -z "${__fsObject}" && echo "ERROR: An die Funktion ${0} wurde keine fsObject übergeben" && exit 106
    test -z "${__group}" && echo "ERROR: An die Funktion ${0} wurde keine Gruppe übergeben" && exit 106
    test -z "${__user}" && echo "ERROR: An die Funktion ${0} wurde keine Owner übergeben" && exit 106
    test -e ${__fsObject} || {
        echo "ERROR: Filesystem Objekt \"${__fsObject}\" existiert nicht"
        exit 106
    }

    chown ${__user}:${__group} ${__fsObject}
    if [[ -d ${__fsObject}  && "${__recurseDirs}." == "recursive." ]]; then
        __recursively="recursively "
        find ${__fsObject} -type d -a \( ! -user ${__user} -o ! -group ${__group} \) -exec chown ${__user}:${__group} {} \;
    fi

    echo "Set owner \"${__user}:${__group}\" on \"${__fsObject}\" ${__recursively}..."
}


##
## sets the directory owner for a directory tree or for the file itself
function createSystemdService {
    local __server=${1}

    test -z "${__server}" && echo "ERROR: An die Funktion ${0} wurde keine Servername übergeben" && exit 107

    __servers=$($WLP_SERVER_CMD list | sed -ne '/^The following servers are defined/,$p' | tail -n+3)
    echo ${__servers} | grep ${__server} 2>1 >/dev/null || {
        echo "ERROR: Servername \"${__server}\" existiert nicht in diesem Profil!"
        exit 107
    }
    ##
    ## Copy systemd file to /etc
    cp bin/liberty@.service /etc/systemd/system || {
        echo "ERROR: Failed to copy liberty@.service to /etc/systemd/system"
        exit 107
    }
    systemctl daemon-reload
    systemctl status liberty@${__server}

    echo "systemctl service liberty@${__server} installed"
}
##
## Objects unaccessible for public and deployers
function deployersLockedOut {
    local __x
    local __y
    ##
    ## __deployersLockedOut is an array of ["<fsObject>" "<mode>"]+
    local __deployersLockedOut=("${WLP_AES_KEY_FILE}" "600" "${WLP_USER_DIR}/shared/resources" "700")
    for __x in ${!__deployersLockedOut[@]}; do
        __y=$((__x+1))
        if [[ $((__x % 2)) -eq 0 ]] ; then
            setOwner "${WLP_BIN_USER}" "${WLP_BIN_GROUP}" "${__deployersLockedOut[${__x}]}"
            setMode ${__deployersLockedOut[${__x}]} ${__deployersLockedOut[${__y}]}
            echo "Locked out deployers of \"${__deployersLockedOut[${__x}]}\" ..."
        fi
    done
}

##
## Open a directory for write access
function setWriteAccessForDeployersGroup {
    local __dir=${1}

    test -z "${__dir}" && echo "ERROR: An die Funktion ${0} wurde keine Verzeichnis übergeben" && exit 108

    setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}"  "${__dir}" "recursive"
    setMode ${__dir} ${__mode}
    chmod g+s ${__dir}

    echo "Set write access for deployers group on \"${__dir}\" ..."
}
##
## Objects to which deployers have read and write access
function deployersWriteAccess {
    local __servers=${1}
    local __mode="770"
    local __x
    local __server
    local __serverDir

    chmod 750 ${WLP_USER_DIR}/servers
    chown "${WLP_BIN_USER}":"${WLP_DEPLOY_GROUP}" ${WLP_USER_DIR}/servers
    for __server in ${__servers} ; do
        __serverDir=${WLP_USER_DIR}/servers/${__server}
        chmod 750 ${__serverDir}
        chown "${WLP_BIN_USER}":"${WLP_DEPLOY_GROUP}" ${__serverDir}
        setWriteAccessForDeployersGroup "${__serverDir}/apps"
        setWriteAccessForDeployersGroup "${__serverDir}/dropins"
        setWriteAccessForDeployersGroup "${__serverDir}/configDropins/defaults"
    done
}


function openLogsForRead {
    local __servers=${1}
    local __serverLogDir
    local __mode="750"

    setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}" "${WLP_LOG_ROOT}"
    setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}" "${WLP_LOG_ROOT}/wlp"
    chmod g+rx "${WLP_LOG_ROOT}"
    chmod g+rx "${WLP_LOG_ROOT}/wlp"
    for __server in ${__servers} ; do
        __serverLogDir=${WLP_LOG_ROOT}/wlp/${__server}/logs
        ##
        ## Allow entering servers log dir for deployers
        setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}" "${WLP_LOG_ROOT}/wlp/${__server}"
        chmod g+rx "${WLP_LOG_ROOT}/wlp/${__server}"
        ##
        ## Need to create ffdc directory for logs to ensure that deployers can access them
        mkdir -p ${__serverLogDir}/ffdc
        ##
        ## Set Owner and mode
        setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}"  "${__serverLogDir}" "recursive"
        setMode ${__serverLogDir} ${__mode}
        chmod g+s ${__serverLogDir}
        chmod g+s ${__serverLogDir}/ffdc
        echo "Set read access for deployers group on \"${__serverLogDir}\" ..."
    done
}
##
## Objects to which deployers have read access
function deployersReadAccess {
    local __servers="${1}"
    local __mode="750"
    local __fileMode="640"
    local __x
    local __server
    local __serverLogDir
    ##
    ## __deployersReadDirs is an array of ["<fsObject>"]+
    local __deployersReadDirs=("${WLP_USER_DIR}/shared/apps" "${WLP_USER_DIR}/shared/config")
    for __x in ${__deployersReadDirs[@]}; do
        setOwner "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}" "${__x}" "recursive"
        chmod g+s ${__x}
        setMode ${__x} ${__mode} ${__fileMode}
        echo "Set read access for deployers group on \"${__x}\" ..."
    done

    openLogsForRead "${__servers}"
}


##
## Code to prepare the VM for the Libery installation
function createPrereqs {
    local __input
    local __file
    local __version
    local __response="n"
    local __confirm=${1:-yes}

    createGroup "${WLP_BIN_GROUP}" ${WLP_BIN_GROUP_GID}
    createGroup "${WLP_DEV_GROUP}" ${WLP_DEV_GROUP_GID}
    createGroup "${WLP_DEPLOY_GROUP}" ${WLP_DEPLOY_GROUP_GID}
    createUserWithPrimaryGroup "${WLP_BIN_USER}" ${WLP_BIN_USER_UID} "${WLP_BIN_GROUP}"
    createUserWithPrimaryGroup "${WLP_DEV_USER}" ${WLP_DEV_USER_UID} "${WLP_DEV_GROUP}"
    addUserToSupGroup "${WLP_BIN_USER}" "${WLP_DEPLOY_GROUP}"
    addUserToSupGroup "${WLP_DEV_USER}" "${WLP_DEPLOY_GROUP}"

    if [[ -d "${WLP_BIN_ROOT}" && "${__confirm,,}" != "-f" ]] ; then
        echo "WARNUNG: Liberty installationsverzeichnis  \"${WLP_BIN_ROOT}\" existiert bereits. Bestehendes Verzeichnis löschen? ([jy]/n)"
        read __input
        __response=${__input,,}
        if [[ "${__response}." =~ [yj]\. ]] ; then
            rm -rf "${WLP_BIN_ROOT}"
        else
            echo "Bestehendes Verzeichnis \"${WLP_BIN_ROOT}\" nicht gelöscht? Script endet ..."
            exit 0
        fi
    else
        rm -rf "${WLP_BIN_ROOT}"
    fi
    createDir "${WLP_BIN_ROOT}"
    chown -R "${WLP_BIN_USER}":"${WLP_BIN_GROUP}" "${WLP_BIN_ROOT}"
    ##
    ## Clone the git repo
    su - "${WLP_BIN_USER}" -c "cd ${WLP_BIN_ROOT} && git clone https://github.com/2innovate/liberty-profile-setup ." || {
        echo "ERROR: Failed to Clone git repo"
        exit 1
    }
    ##
    ## Download Liberty & Java
    su - "${WLP_BIN_USER}" -c "cd ${WLP_BIN_ROOT} && mkdir -p java downloads && cd downloads && curl -LO ${JAVA_URL} && curl -LO ${LIBERTY_URL}" || {
        echo "ERROR: Failed to download binaries"
        exit 1
    }
    ##
    ## Unpack Java
    su - "${WLP_BIN_USER}" -c "cd ${WLP_BIN_ROOT}/java && tar xvzf ../downloads/${JAVA_URL##*/}"
    ##
    ## Unpack Liberty
    __file=$(echo ${LIBERTY_URL##*/})
    ##
    ## Get version number
    [[ ${__file} =~ "openliberty-"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\..* ]]
    __version=${BASH_REMATCH[1]}
    su - "${WLP_BIN_USER}" -c "cd ${WLP_BIN_ROOT} && unzip -d wlp-base-all-${__version} downloads/${LIBERTY_URL##*/}"
}

function hardenInstallation {
    ##
    ## Get the servers
    servers=$($WLP_SERVER_CMD list | sed -ne '/^The following servers are defined/,$p' | tail -n+3 | tr "\n" " ")
    ##
    ## Set the default overship to the liberty owner only
    setOwner "${WLP_BIN_USER}" "${WLP_BIN_GROUP}" "${WLP_BIN_ROOT}" "recursive"
    ##
    ## Lockout deployers for certain objects
    echo "Locking out deployers from sensitve area ..."
    deployersLockedOut
    echo "Opening directories for write access for deployers ..."
    deployersWriteAccess "${servers}"
    echo "Opening directories for read access for deployers ..."
    deployersReadAccess "${servers}"
}

function checkSetup {
    test ! -d "$JAVA_HOME"      && {
        echo -e "ERROR: Java Home existiert nicht: '$JAVA_HOME'"
        exit 1
    }
    test ! -d "$WLP_BIN_DIR"    && {
        echo -e "ERROR: Liberty Verzeichnis existiert nicht: '$WLP_BIN_DIR'"
        exit 1
    }
    test ! -f "$WLP_SERVER_CMD" && {
        echo -e "ERROR: Liberty Server Command nicht gefunden: '$WLP_SERVER_CMD'"
        exit 1
    }
    return 0
}
#
# ================================================================================
# ================================================================================
#   MAIN
# ================================================================================
# Checks
##
## Ensure we are running as root
test "$(whoami)" == "root" || {
    echo "ERROR: Diese Funktion muss als root ausgeführt werden ..."
    exit 1
}
##
## Change to the script directory
cd $(dirname ${0})

# CMD LINE ARG CHECK
ACTION=${1:---help}   ## lowercase transform
ACTION=${ACTION,,}   ## lowercase transform



if [ "${ACTION}" = "harden" ]; then
    checkSetup
    hardenInstallation
elif [[ "${ACTION}" = "prereqs" ]]; then
    ##
    ## Herstellen der Voraussetzungen
    CONFIRM=${2:-yes}
    createPrereqs ${CONFIRM}
elif [[ "${ACTION}" = "systemd" ]]; then
    checkSetup
    WLP_SERVER_NAME=${2?ERROR: Arg1: Kein SERVERNAME angegeben.}
    createSystemdService ${WLP_SERVER_NAME}

elif [[ "${ACTION}" =~ ^-+h(elp)?$ ]]; then
    usage

else
    echo -e "ERROR: Unbekanntes COMMAND: $ACTION\n"
    usage
fi
