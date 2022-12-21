# liberty-profile-setup

## Prerequisites
- create user `liberty` and p.group `liberty`
- create folder `/opt/liberty` and chown
```
sudo groupadd liberty
sudo useradd -m -g liberty liberty
sudo mkdir /opt/liberty
sudo chown -R liberty:liberty /opt/liberty
```

## clone repo to /opt/liberty
```
cd /opt/liberty
git clone https://github.com/2innovate/liberty-profile-setup .
```

## download JDK and OpenLiberty archives and extract them
- unzip JDK to `java/`
- unzip openliberty to `liberty/wlp-base-all-22.0.0.12`
```
cd downloads
curl -LO https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/22.0.0.12/openliberty-22.0.0.12.zip
curl -LO https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.5%2B8_openj9-0.35.0/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz

cd ../java
tar xvzf ../downloads/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz

cd ..
unzip -d wlp-base-all-22.0.0.12 ../downloads/openliberty-22.0.0.12.zip
```
