#!/bin/bash -e
##
## Soure customizations
. $(dirname ${0})/liberty_settings.sh

WLP_SERVER_NAME=${1}
test -z "${WLP_SERVER_NAME}"        && {
                        echo "no server name provided ..."
                        exit 1
                        }

# CONFIGURATION OVERRIDE file JAAS Authentication data
cat << "EOM" > ${WLP_SERVER_DIR}/configDropins/overrides/federatedRepository.xml
<server description="Federated repository definition">
    <ldapRegistry host="ldapisimtt.pva.sozvers.at"
    	baseDN="dc=pva,dc=sozvers,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_PVA"
    	bindDN="cn=02attidm,cn=Users,dc=pva,dc=sozvers,dc=at"
    	bindPassword="{aes}AME1P/orSTyDpXKtZMxzY1Eh7Lwk5+l3jA3eupITKddp9bDBg/ITodyF5Tcv3l2ENg=="
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="${env.keystore_password}">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="pvaGroup">
    		<searchBase>cn=Roles,dc=pva,dc=sozvers,dc=at</searchBase>
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
    		<searchBase>cn=Users,dc=pva,dc=sozvers,dc=at</searchBase>
			<searchFilter>(|(uid=02*)(pvaTechnischerBenutzer=true))</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.pva.sozvers.at"
    	baseDN="dc=sva,dc=sozvers,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_SVA"
    	bindDN="cn=02attidm,cn=Users,dc=pva,dc=sozvers,dc=at"
    	bindPassword="{aes}AME1P/orSTyDpXKtZMxzY1Eh7Lwk5+l3jA3eupITKddp9bDBg/ITodyF5Tcv3l2ENg=="
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="${env.keystore_password}">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="svaGroup">
    		<searchBase>cn=Roles,dc=sva,dc=sozvers,dc=at</searchBase>
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
    		<searchBase>cn=Users,dc=sva,dc=sozvers,dc=at</searchBase>
			<searchFilter>(uid=40*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
    	</groupProperties>

    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.pva.sozvers.at"
    	baseDN="dc=svb,dc=sozvers,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_SVB"
    	bindDN="cn=02attidm,cn=Users,dc=pva,dc=sozvers,dc=at"
    	bindPassword="{aes}AME1P/orSTyDpXKtZMxzY1Eh7Lwk5+l3jA3eupITKddp9bDBg/ITodyF5Tcv3l2ENg=="
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="${env.keystore_password}">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="svbGroup">
    		<searchBase>cn=Roles,dc=svb,dc=sozvers,dc=at</searchBase>
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
    		<searchBase>cn=Users,dc=svb,dc=sozvers,dc=at</searchBase>
			<searchFilter>(uid=50*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <ldapRegistry host="ldapisimtt.pva.sozvers.at"
    	baseDN="dc=vaeb,dc=sozvers,dc=at" port="10389" ldapType="Custom"
    	id="OpenLDAP_VAEB"
    	bindDN="cn=02attidm,cn=Users,dc=pva,dc=sozvers,dc=at"
    	bindPassword="{aes}AME1P/orSTyDpXKtZMxzY1Eh7Lwk5+l3jA3eupITKddp9bDBg/ITodyF5Tcv3l2ENg=="
    	ignoreCase="true" reuseConnection="true" recursiveSearch="true"
    	searchTimeout="15s" connectTimeout="5s" readTimeout="15s"
    	primaryServerQueryTimeInterval="15" returnToPrimaryServer="true" derefAliases="always" referral="ignore" sslRef="${env.keystore_password}">
    	<ldapCache>
    		<attributesCache enabled="false" size="2000" timeout="20m" sizeLimit="2000"></attributesCache>
    	</ldapCache>
    	<ldapCache>
    		<searchResultsCache enabled="false" size="2000" timeout="20m" resultsSizeLimit="2000"></searchResultsCache>
    	</ldapCache>
    	<ldapEntityType name="Group" id="vaebGroup">
    		<searchBase>cn=Roles,dc=vaeb,dc=sozvers,dc=at</searchBase>
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
    		<searchBase>cn=Users,dc=vaeb,dc=sozvers,dc=at</searchBase>
			<searchFilter>(uid=50*)</searchFilter>
    	</ldapEntityType>
    	<groupProperties>
    		<memberAttribute objectClass="groupOfNames" name="member" scope="direct"></memberAttribute>
    		<memberAttribute objectClass="groupOfUniqueNames" name="uniqueMember" scope="direct"></memberAttribute>
		</groupProperties>
    </ldapRegistry>

    <federatedRepository maxSearchResults="4500" searchTimeout="10m"
    	pageCacheSize="1000" pageCacheTimeout="15m" id="PVASecurityFederatedRepository">
    	<realm name="defaultWIMFileBasedRealm" id="PVASecurity" allowOpIfRepoDown="true" delimiter="/">
    		<groupDisplayNameMapping inputProperty="cn" outputProperty="cn" />
    		<groupSecurityNameMapping inputProperty="cn" outputProperty="cn" />
    		<uniqueGroupIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<userDisplayNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<userSecurityNameMapping inputProperty="principalName" outputProperty="principalName" />
    		<uniqueUserIdMapping inputProperty="uniqueName" outputProperty="uniqueName" />
    		<participatingBaseEntry name="dc=vaeb,dc=sozvers,dc=at" id="vaeb" />
    		<participatingBaseEntry name="dc=svb,dc=sozvers,dc=at" id="svb" />
    		<participatingBaseEntry name="dc=sva,dc=sozvers,dc=at" id="sva" />
    		<participatingBaseEntry name="dc=pva,dc=sozvers,dc=at" id="pva" />
    	</realm>
    	<supportedEntityType id="groupMappingReference">
    		<name>Group</name>
    		<defaultParent>o=defaultWIMFileBasedRealm</defaultParent>
    	</supportedEntityType>
    	<supportedEntityType id="orgContainerMappingReference">
    		<name>OrgContainer</name>
    		<defaultParent>o=defaultWIMFileBasedRealm</defaultParent>
    	</supportedEntityType>
    	<supportedEntityType id="personAccountMappingReference">
    		<name>PersonAccount</name>
    		<defaultParent>o=defaultWIMFileBasedRealm</defaultParent>
    	</supportedEntityType>
    </federatedRepository>
</server>
