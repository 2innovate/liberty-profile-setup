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
mkdir -p ${WLP_USER_DIR}/shared/resources/adapters/jdbc/oracle
mkdir -p ${WLP_USER_DIR}/shared/resources/adapters/jdbc/db2

# CONFIGURATION OVERRIDE file JAAS Authentication data
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/db2DS.xml
<server description="JAAS Authentication data">
    <featureManager>
        <feature>jakartaee-9.1</feature>
    </featureManager>

    <authData id="db2AuthData" user="db2inst1" password="{aes}AJ4AGznY45FRBP3wmpIXERQGFEvZlz2jvfC70E7lMFvq"></authData>
    <connectionManager id="db2CM" agedTimeout="2h" connectionTimeout="5s" minPoolSize="0" maxIdleTime="30m" maxPoolSize="50" purgePolicy="EntirePool" reapTime="5m"></connectionManager>
    <library id="db2Lib" name="db2Lib" description="Shared library for DB2 JDBC driver">
        <fileset dir="${shared.resource.dir}/adapters/jdbc/db2" includes="db2jcc4.jar db2jcc_license_cu.jar"></fileset>
    </library>
    <jdbcDriver libraryRef="db2Lib" id="db2XADriver" javax.sql.XADataSource="com.ibm.db2.jcc.DB2XADataSource" >
    </jdbcDriver>
    <dataSource id="db2DB" jndiName="jdbc/db2DS" jdbcDriverRef="db2XADriver" containerAuthDataRef="db2AuthData" statementCacheSize="10" connectionManagerRef="db2CM" recoveryAuthDataRef="db2AuthData" type="javax.sql.XADataSource" >
        <properties databaseName="HHUE" serverName="localhost" portNumber="60000" driverType="4"  />
    </dataSource>
</server>
EOM
