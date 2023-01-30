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
                <user name="05dom4"/>
                <user name="40dom2"/>
                <user name="50dom3"/>
                <user name="02dom1"/>
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
    	baseDN="dc=dom1,dc=2i,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_2I"
    	bindDN="cn=02attidm,cn=Users,dc=dom1,dc=dummy,dc=at"
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
    	<ldapEntityType name="Group" id="dom1Group">
    		<searchBase>cn=Roles,dc=dom1,dc=dummy,dc=at</searchBase>
    		<objectClass>dom1Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="dom1OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="dom1PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>dom1Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>cn=Users,dc=dom1,dc=dummy,dc=at</searchBase>
			<searchFilter>(|(uid=02*)(dom1TechnischerBenutzer=true))</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.dom1.dummy.at"
    	baseDN="dc=dom2,dc=dummy,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_SVA"
    	bindDN="cn=02attidm,cn=Users,dc=dom1,dc=dummy,dc=at"
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
    	<ldapEntityType name="Group" id="dom2Group">
    		<searchBase>cn=Roles,dc=dom2,dc=dummy,dc=at</searchBase>
    		<objectClass>dom1Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="dom2OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="dom2PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>dom1Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>cn=Users,dc=dom2,dc=dummy,dc=at</searchBase>
			<searchFilter>(uid=40*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.dom1.dummy.at"
    	baseDN="dc=dom3,dc=dummy,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_SVB"
    	bindDN="cn=02attidm,cn=Users,dc=dom1,dc=dummy,dc=at"
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
    	<ldapEntityType name="Group" id="dom3Group">
    		<searchBase>cn=Roles,dc=dom3,dc=dummy,dc=at</searchBase>
    		<objectClass>dom1Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="dom3OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="dom3PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>dom1Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>cn=Users,dc=dom3,dc=dummy,dc=at</searchBase>
			<searchFilter>(uid=50*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.dom1.dummy.at"
    	baseDN="dc=dom4,dc=dummy,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_VAEB"
    	bindDN="cn=02attidm,cn=Users,dc=dom1,dc=dummy,dc=at"
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
    	<ldapEntityType name="Group" id="dom4Group">
    		<searchBase>cn=Roles,dc=dom4,dc=dummy,dc=at</searchBase>
    		<objectClass>dom1Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="dom4OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="dom4PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>dom1Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>cn=Users,dc=dom4,dc=dummy,dc=at</searchBase>
			<searchFilter>(uid=05*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <federatedRepository maxSearchResults="4500" searchTimeout="10m"
    	pageCacheSize="1000" pageCacheTimeout="15m" id="2ISecurityFederatedRepository">
		<primaryRealm name="defaultWIMFileBasedRealm" id="2IPrimary" allowOpIfRepoDown="true">
            <participatingBaseEntry name="dc=dom1,dc=dummy,dc=at"/>
            <participatingBaseEntry name="dc=dom2,dc=dummy,dc=at"/>
            <participatingBaseEntry name="dc=dom3,dc=dummy,dc=at"/>
            <participatingBaseEntry name="dc=dom4,dc=dummy,dc=at"/>
        </primaryRealm>
    	<realm name="defaultWIMFileBasedRealm" id="2ISecurity" allowOpIfRepoDown="true" delimiter="/">
    		<groupDisplayNameMapping inputProperty="cn" outputProperty="cn" />
    		<groupSecurityNameMapping inputProperty="cn" outputProperty="cn" />
    		<uniqueGroupIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<userDisplayNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<userSecurityNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<uniqueUserIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<participatingBaseEntry name="dc=dom4,dc=dummy,dc=at" id="dom4" />
    		<participatingBaseEntry name="dc=dom3,dc=dummy,dc=at" id="dom3" />
    		<participatingBaseEntry name="dc=dom2,dc=dummy,dc=at" id="dom2" />
    		<participatingBaseEntry name="dc=dom1,dc=dummy,dc=at" id="dom1" />
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
