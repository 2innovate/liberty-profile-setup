# liberty-profile-setup

## Prerequisites

- create user `liberty` and p.group `liberty`
- create folder `/opt/liberty` and chown

```
sudo groupadd liberty
sudo groupadd libdev
sudo groupadd libdeploy
sudo useradd -m -g liberty liberty
sudo useradd -m -g libdev libdev
sudo usermod -a -G libdeploy liberty
sudo usermod -a -G libdeploy libdev
sudo mkdir /opt/liberty
sudo chown -R liberty:liberty /opt/liberty
sudo loginctl enable-linger liberty
```
**Note**: To create the prerequisites in an automated fashion you can clone the repo (run: `git clone https://github.com/2innovate/liberty-profile-setup`) as root or any user who can become root via sudo and then run: `./rootTasks.sh prereqs` as root (or by running `sudo ./rootTasks.sh prereqs` if you are not root)

## clone repo to /opt/liberty as user `liberty`

```
sudo su - liberty
cd /opt/liberty
git clone https://github.com/2innovate/liberty-profile-setup .
```

## download OpenJDK and OpenLiberty archives and extract them

- unzip JDK to `java/`
- unzip openliberty to `liberty/wlp-base-all-22.0.0.12`

```
mkdir java downloads
cd downloads
curl -LO https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/22.0.0.12/openliberty-22.0.0.12.zip
curl -LO https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.5%2B8_openj9-0.35.0/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz

cd ../java
tar xvzf ../downloads/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz

cd ..
unzip -d wlp-base-all-22.0.0.12 downloads/openliberty-22.0.0.12.zip
```

# Use `rootTasks.sh`

Use the `rootTasks.sh` script to perform tasks requiring root access. I.e these tasks can either be executed as root or using `sudo` to run the tasks:

```
    ./rootTasks.sh <command> <options>

      command:  harden, prereqs

      - harden                  setzt Gruppenberechtigungen und die Berechtigungen am Filesystem (requires root)
      - prereqs                 erstellt die pre-requisites am Server (requires root)
      - systemd NAME            erstellen systemctl service for server NAME (requires root)
```

## Command `prereqs`

This commad of the `rootTasks.sh`  prepares a server by creating the required users, groups and downloading the files for Java and Liberty installation. The download URLs are defined in `liberty-settings.sh` via the variables *JAVA_URL* and *LIBERTY_URL*.

If the directory exists the script prompts for deletion of the existing directory unless *-f* is set.

## Command `systemd`

This command creates the required *systemd* files to install a service for the server named *NAME*

## Command `harden`

This command sets the required permissions for the devlopers so that these can deploy applications, configure Liberty at the lowest priority and view the log files.

### Read access for the developers

Developers get read access to the following directories:
- ${WLP_LOG_ROOT}/wlp/$server/logs --> /opt/liberty/logs/wlp/$server/logs
- ${WLP_LOG_ROOT}/wlp/$server/logs/ffdc --> /opt/liberty/logs/wlp/$server/logs/ffdc
- ${WLP_USER_DIR}/shared/apps --> /opt/liberty/profiles/wlp/shared/apps
- ${WLP_USER_DIR}/shared/config --> /opt/liberty/profiles/wlp/shared/config

### Write access for developers

Developers get write access to the following directories
- WLP_SERVER_DIR=$WLP_USER_DIR/servers/$server
- ${WLP_SERVER_DIR}/apps --> /opt/liberty/profiles/wlp/servers/$server/apps
- ${WLP_SERVER_DIR}/dropins --> /opt/liberty/profiles/wlp/servers/$server/dropins
- ${WLP_SERVER_DIR}/configDropins/defaults --> /opt/liberty/profiles/wlp/servers/$server/configDropins/defaults

### Developers lock out

Developers are locked out of the following file-system objects:
- ${WLP_AES_KEY_FILE} --> /opt/liberty/profiles/wlp/shared/resources/security/aesKey.properties
- ${WLP_USER_DIR}/shared/resources  --> /opt/liberty/profiles/wlp/shared/resources

# Use `manageprofiles.sh`

Use `manageprofiles` script to easily setup multiple Liberty server instances:

```
$ ./manageprofiles.sh

    ./manageprofiles.sh <command> <options>

      command:  list, create, run, status, status-all, harden, prereqs

      - list                    zeigt alle definierten Liberty Server an
      - create NAME [OFFSET]    legt einen neuen Liberty Server mit Namen und Port 10080 + OFFSET (std: 0) an
      - systemd NAME            erstellt ein --user systemd service für server NAME
      - delete NAME [-f]        loescht den genannten Liberty Server (inkl Logs). '-f ' loescht ohne nach zu fragen!
      - run    NAME             starten den Liberty 0) anr im Vordergrund (Strg-C um abzubrechen!)S
      - status NAME             zeigt den Serverstatus eines Servers an
      - status-all              zeigt den Serverstatus aller Liberty Server an
```

## create 2 server instances

```
./manageprofiles.sh create server1
./manageprofiles.sh create server2 1
```

# Start/stop servers using systemd

Copy service file `liberty/bin/liberty@.service` to /etc/systemd/system

```
sudo cp bin/liberty@.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl status liberty@server1
```
