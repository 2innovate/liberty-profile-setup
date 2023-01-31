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

if [[ -f $(dirname ${0})/federatedRepoValues.sh ]] ; then
	source $(dirname ${0})/federatedRepoValues.sh
	echo "Using $(dirname ${0})/federatedRepoValues.sh ..."
else
	if [[ -f ~/federatedRepoValues.sh ]] ; then
		source ~/federatedRepoValues.sh
		echo "Using ~/federatedRepoValues.sh ..."
	else
		echo "ERRORS: No Values file federatedRepoValues.sh found!!"
		exit 1
	fi
fi

# CONFIGURATION OVERRIDE file WAR Deployment
cat << EOM > ${WLP_SERVER_DIR}/configDropins/defaults/ServletSample.xml
<server description="App definition">
    <application id="ServletSample" name="ServletSample" location="\${server.config.dir}/apps/ServletSample.war" type="war">
        <application-bnd>
            <!-- this can also be defined in web.xml instead -->
            <security-role name="admin">
                <user name="05${LDAP_DOM4}"/>
                <user name="40${LDAP_DOM2}"/>
                <user name="50${LDAP_DOM3}"/>
                <user name="02${LDAP_DOM1}"/>
            </security-role>
        </application-bnd>
    </application>
</server>
EOM

# CONFIGURATION OVERRIDE Inlcude the federated repository
cat << EOM > ${WLP_SERVER_DIR}/configDropins/overrides/ltpa.xml
<server description="Ltpa sefinition">
    <ltpa keysFileName="\${WLP_USER_DIR}/shared/resources/security/ltpa.keys" keysPassword="{aes}ALoerrEsXW40OpY2Cntrxb18WRvlh05856JdO2YmAsmI" expiration="120" />

</server>
EOM

# CONFIGURATION OVERRIDE Inlcude the federated repository
cat << EOM > ${WLP_SERVER_DIR}/configDropins/overrides/federatedRepository.xml
<server description="Include federated repository">
<include optional="false" location="\${WLP_USER_DIR}/shared/config/federatedRepository.xml"/>
</server>
EOM

cat << EOM > ${WLP_USER_DIR}/shared/config/federatedRepository.xml
<server description="Federated repository definition">
    <featureManager>
        <feature>federatedRegistry-1.0</feature>
        <feature>ldapRegistry-3.0</feature>
    </featureManager>

    <ldapRegistry host="${LDAP_HOST_1}"
    	baseDN="dc=${LDAP_DOM1},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" port="${LDAP_PORT_1}" ldapType="Custom"
    	id="OpenLDAP_${LDAP_DOM1^^}"
    	bindDN="${LDAP_BIND_DN_1}"
    	bindPassword="${LDAP_BIND_PWD_1}"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="${LDAP_DOM1}Group">
    		<searchBase>${LDAP_GROUP_SEARCH_BASE},dc=${LDAP_DOM1},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
    		<objectClass>${LDAP_DOM1}Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="${LDAP_DOM1}OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="${LDAP_DOM1}PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>${LDAP_DOM1}Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>${LDAP_USER_SEARCH_BASE},dc=${LDAP_DOM1},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
			<searchFilter>(|(uid=02*)(${LDAP_DOM1}TechnischerBenutzer=true))</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="${LDAP_HOST_2}"
    	baseDN="dc=${LDAP_DOM2},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" port="${LDAP_PORT_2}" ldapType="Custom"
    	id="OpenLDAP_${LDAP_DOM2^^}"
    	bindDN="${LDAP_BIND_DN_2}"
    	bindPassword="${LDAP_BIND_PWD_2}"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="${LDAP_DOM2}Group">
    		<searchBase>${LDAP_GROUP_SEARCH_BASE},dc=${LDAP_DOM2},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
    		<objectClass>${LDAP_DOM1}Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="${LDAP_DOM2}OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="${LDAP_DOM2}PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>${LDAP_DOM1}Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>${LDAP_USER_SEARCH_BASE},dc=${LDAP_DOM2},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
			<searchFilter>(uid=40*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="${LDAP_HOST_3}"
    	baseDN="dc=${LDAP_DOM3},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_${LDAP_DOM3^^}"
    	bindDN="${LDAP_BIND_DN_3}"
    	bindPassword="${LDAP_BIND_PWD_3}"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="${LDAP_DOM3}Group">
    		<searchBase>${LDAP_GROUP_SEARCH_BASE},dc=${LDAP_DOM3},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
    		<objectClass>${LDAP_DOM1}Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="${LDAP_DOM3}OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="${LDAP_DOM3}PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>${LDAP_DOM1}Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>${LDAP_USER_SEARCH_BASE},dc=${LDAP_DOM3},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
			<searchFilter>(uid=50*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="${LDAP_HOST_4}"
    	baseDN="dc=${LDAP_DOM4},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_${LDAP_DOM4^^}"
    	bindDN="${LDAP_BIND_DN_4}"
    	bindPassword="${LDAP_BIND_PWD_4}"
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="defaultSSLConfig">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="${LDAP_DOM4}Group">
    		<searchBase>${LDAP_GROUP_SEARCH_BASE},dc=${LDAP_DOM4},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
    		<objectClass>${LDAP_DOM1}Group</objectClass>
    		<objectClass>posixGroup</objectClass>
    		<objectClass>groupOfUniqueNames</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="OrgContainer" id="${LDAP_DOM4}OrgContainer">
    		<objectClass>organization</objectClass>
    		<objectClass>organizationalUnit</objectClass>
    		<objectClass>domain</objectClass>
    		<objectClass>container</objectClass>
    	</ldapEntityType>
    	<ldapEntityType name="PersonAccount" id="${LDAP_DOM4}PersonAccount">
    		<objectClass>person</objectClass>
    		<objectClass>organizationalPerson</objectClass>
    		<objectClass>user</objectClass>
    		<objectClass>${LDAP_DOM1}Mitarbeiter</objectClass>
    		<objectClass>inetOrgPerson</objectClass>
    		<searchBase>${LDAP_USER_SEARCH_BASE},dc=${LDAP_DOM4},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at</searchBase>
			<searchFilter>(uid=05*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <federatedRepository maxSearchResults="4500" searchTimeout="10m"
    	pageCacheSize="1000" pageCacheTimeout="15m" id="${LDAP_DOM1_CAPS}SecurityFederatedRepository">
		<primaryRealm name="defaultWIMFileBasedRealm" id="${LDAP_DOM1_CAPS}Primary" allowOpIfRepoDown="true">
            <participatingBaseEntry name="dc=${LDAP_DOM1},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at"/>
            <participatingBaseEntry name="dc=${LDAP_DOM2},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at"/>
            <participatingBaseEntry name="dc=${LDAP_DOM3},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at"/>
            <participatingBaseEntry name="dc=${LDAP_DOM4},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at"/>
        </primaryRealm>
    	<realm name="defaultWIMFileBasedRealm" id="${LDAP_DOM1_CAPS}Security" allowOpIfRepoDown="true" delimiter="/">
    		<groupDisplayNameMapping inputProperty="cn" outputProperty="cn" />
    		<groupSecurityNameMapping inputProperty="cn" outputProperty="cn" />
    		<uniqueGroupIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<userDisplayNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<userSecurityNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<uniqueUserIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<participatingBaseEntry name="dc=${LDAP_DOM4},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" id="${LDAP_DOM4}" />
    		<participatingBaseEntry name="dc=${LDAP_DOM3},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" id="${LDAP_DOM3}" />
    		<participatingBaseEntry name="dc=${LDAP_DOM2},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" id="${LDAP_DOM2}" />
    		<participatingBaseEntry name="dc=${LDAP_DOM1},dc=${LDAP_DNS_SUBDOMAIN_1},dc=at" id="${LDAP_DOM1}" />
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
