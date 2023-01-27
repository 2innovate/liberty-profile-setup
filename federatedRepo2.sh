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

# CONFIGURATION OVERRIDE file WAR Deployment
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/defaults/ServletSample.xml
<server description="App definition">
    <application id="ServletSample" name="ServletSample" location="${server.config.dir}/apps/ServletSample.war" type="war">
        <application-bnd>
            <!-- this can also be defined in web.xml instead -->
            <security-role name="admin">
                <user name="05vaeb"/>
                <user name="40sva"/>
                <user name="50svb"/>
                <user name="02pva"/>
            </security-role>
        </application-bnd>
    </application>
</server>
EOM

# CONFIGURATION OVERRIDE Inlcude the federated repository
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/ltpa.xml
<server description="Ltpa sefinition">
    <ltpa keysFileName="${WLP_USER_DIR}/shared/resources/security/ltpa.keys" keysPassword="{aes}ALoerrEsXW40OpY2Cntrxb18WRvlh05856JdO2YmAsmI" expiration="120" />
</server>
EOM

# CONFIGURATION OVERRIDE Inlcude the federated repository
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/federatedRepository.xml
<server description="Include federated repository">
<include optional="false" location="${WLP_USER_DIR}/shared/config/federatedRepository.xml"/>
</server>
EOM

cat << "EOM" > ${WLP_USER_DIR}/shared/config/federatedRepository.xml
<server description="Federated repository definition">
    <featureManager>
        <feature>federatedRegistry-1.0</feature>
        <feature>ldapRegistry-3.0</feature>
    </featureManager>

    <ldapRegistry host="epyc.2i.at"
    	baseDN="dc=pva,dc=2i,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_PVA"
    	bindDN="cn=admin,dc=pva,dc=2i,dc=at"
    	bindPassword="{aes}AISP+7C2S0ZAxaqk7zfyUGH4Flt/Hv9kreNqwnyyWsW9"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="pvaGroup">
    		<searchBase>ou=groups,ou=ocp00,dc=pva,dc=2i,dc=at</searchBase>
    		<objectClass>pvaGroup</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="pvaOrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="pvaPersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>pvaMitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>ou=users,ou=ocp00,dc=pva,dc=2i,dc=at</searchBase>
			<searchFilter>(|(uid=02*)(pvaTechnischerBenutzer=true))</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="epyc.2i.at"
    	baseDN="dc=sva,dc=2i,dc=at" port="10390" ldapType="Custom"
    	id="OpenLDAP_SVA"
    	bindDN="cn=admin,dc=sva,dc=2i,dc=at"
    	bindPassword="{aes}AISP+7C2S0ZAxaqk7zfyUGH4Flt/Hv9kreNqwnyyWsW9"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="svaGroup">
    		<searchBase>ou=groups,ou=ocp00,dc=sva,dc=2i,dc=at</searchBase>
    		<objectClass>pvaGroup</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="svaOrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="svaPersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>pvaMitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>ou=users,ou=ocp00,dc=sva,dc=2i,dc=at</searchBase>
			<searchFilter>(uid=40*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="epyc.2i.at"
    	baseDN="dc=svb,dc=2i,dc=at" port="10391" ldapType="Custom"
    	id="OpenLDAP_SVB"
    	bindDN="cn=admin,dc=svb,dc=2i,dc=at"
    	bindPassword="{aes}AISP+7C2S0ZAxaqk7zfyUGH4Flt/Hv9kreNqwnyyWsW9"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="svbGroup">
    		<searchBase>ou=groups,ou=ocp00,dc=svb,dc=2i,dc=at</searchBase>
    		<objectClass>pvaGroup</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="svbOrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="svbPersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>pvaMitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>ou=users,ou=ocp00,dc=svb,dc=2i,dc=at</searchBase>
			<searchFilter>(uid=50*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="epyc.2i.at"
    	baseDN="dc=vaeb,dc=2i,dc=at" port="10392" ldapType="Custom"
    	id="OpenLDAP_VAEB"
    	bindDN="cn=admin,dc=vaeb,dc=2i,dc=at"
    	bindPassword="{aes}AISP+7C2S0ZAxaqk7zfyUGH4Flt/Hv9kreNqwnyyWsW9"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="vaebGroup">
    		<searchBase>ou=groups,ou=ocp00,dc=vaeb,dc=2i,dc=at</searchBase>
    		<objectClass>pvaGroup</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="vaebOrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="vaebPersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>pvaMitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>ou=users,ou=ocp00,dc=vaeb,dc=2i,dc=at</searchBase>
			<searchFilter>(uid=05*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <federatedRepository maxSearchResults="4500" searchTimeout="10m" pageCacheSize="1000" pageCacheTimeout="15m" id="PVASecurityFederatedRepository">
        <primaryRealm name="defaultWIMFileBasedRealm" id="PVAPrimary" allowOpIfRepoDown="true">
            <participatingBaseEntry name="dc=pva,dc=2i,dc=at"/>
            <participatingBaseEntry name="dc=sva,dc=2i,dc=at"/>
            <participatingBaseEntry name="dc=svb,dc=2i,dc=at"/>
            <participatingBaseEntry name="dc=vaeb,dc=2i,dc=at"/>
        </primaryRealm>
    	<realm name="defaultWIMFileBasedRealm" id="PVASecurity" allowOpIfRepoDown="true" delimiter="/">
    		<groupDisplayNameMapping inputProperty="cn" outputProperty="cn" />
    		<groupSecurityNameMapping inputProperty="cn" outputProperty="cn" />
    		<uniqueGroupIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<userDisplayNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<userSecurityNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<uniqueUserIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<participatingBaseEntry  name="dc=vaeb,dc=2i,dc=at" id="vaeb" />
    		<participatingBaseEntry  name="dc=svb,dc=2i,dc=at"  id="svb" />
    		<participatingBaseEntry  name="dc=sva,dc=2i,dc=at"  id="sva" />
    		<participatingBaseEntry  name="dc=pva,dc=2i,dc=at"  id="pva" />
    	</realm>
    	<supportedEntityType id="groupMappingReference">
    		<name>Group</name>
    		<defaultParent>o=BasicRegistry</defaultParent>
    	</supportedEntityType>
    	<supportedEntityType id="orgContainerMappingReference">
    		<name>OrgContainer</name>
    		<defaultParent>o=BasicRegistry</defaultParent>
    	</supportedEntityType>
    	<supportedEntityType id="personAccountMappingReference">
    		<name>PersonAccount</name>
    		<defaultParent>o=BasicRegistry</defaultParent>
    	</supportedEntityType>
    </federatedRepository>
</server>
EOM
