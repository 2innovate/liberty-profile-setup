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
mkdir -p ${WLP_USER_DIR}/shared/resources/jdbc/oracle

# CONFIGURATION OVERRIDE file JAAS Authentication data
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/jaas_authdata.xml
<server description="JAAS Authentication data">
    <authData id="oracle8AuthData" user="oracleUser" password="{aes}AAd4cNsvnJWulvb7PS3f/vtF6fRByg4a5WRhL+o9QOi5"></authData>
</server>
EOM

# CONFIGURATION OVERRIDE file Connection Manager data
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/connectionMananger.xml
<server description="Connection manager">
    <connectionManager id="oracle8CM" agedTimeout="2h" connectionTimeout="5s" minPoolSize="0" maxIdleTime="30m" maxPoolSize="50" purgePolicy="EntirePool" reapTime="5m"></connectionManager>
</server>
EOM

# CONFIGURATION OVERRIDE file Oracle-8 JDBC Driver
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/oracle-driver.xml
<server description="Oracle JDBC driver">

    <library id="oracle7Lib" name="oracle7Lib" description="Shared library for Oracle 7 JDBC driver">
        <fileset dir="${shared.resource.dir}/jdbc/oracle" includes="ojdbc7.jar xdb6.jar"></fileset>
    </library>
    <library id="oracle8Lib" name="oracle8Lib" description="Shared library for Oracle 8 JDBC driver">
        <fileset dir="${shared.resource.dir}/jdbc/oracle" includes="ojdbc8.jar"></fileset>
    </library>

    <jdbcDriver libraryRef="oracle8Lib" id="oracle8XADriver" type="oracle.jdbc.xa.client.OracleXADataSource">
    </jdbcDriver>
    <jdbcDriver id="oracle8CPDriver" libraryRef="oracle8Lib" type="oracle.jdbc.pool.OracleConnectionPoolDataSource "></jdbcDriver>

</server>
EOM

# CONFIGURATION OVERRIDE file Oracle-8 JDBC Datasource
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/oracle-ds.xml
<server description="Oracle JDBC Datasource">
    <featureManager>
        <feature>jdbc-4.2</feature>
    </featureManager>

    <dataSource id="oracle8DSSampleDB" jndiName="jdbc/exampleDS" jdbcDriverRef="oracle8XADriver" containerAuthDataRef="oracle8AuthData" statementCacheSize="10" connectionManagerRef="oracle8CM" recoveryAuthDataRef="oracle8AuthData" type="javax.sql.XADataSource" >
        <properties  driverType="thin" databaseName="pvintern" serverName="localhost" portNumber="1521" URL="jdbc:oracle:thin:@localhost:1521:pvintern"></properties>
    </dataSource>

</server>
EOM
