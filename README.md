# Intro
This repo contains two containers:
* keycloak which uses the keycloak-eid container as identity provider
* keycloak-eid which is an identity provider responsible of validating the e-id and returning the ssn number to the keycloak container

# Todo
* ~~Set up a second Keycloak instance~~
* ~~The first Keycloak instance will NOT be configured for mutual SSL~~
* ~~The second Keycloak instance will be configured for mutual SSL and will be an identity provider to the first instance~~
* ~~The second Keycloak instance will use the certificate's serial number to extract the SSN and place it in a token which is sent to the first instance.~~
* ~~The first instance will consider this as a 'registration' of the user, by setting some arbitrary user claim or by adding that user to a group.~~

Reason for two instances: the mutual SSL is set up on server level, and no application configuration can establish that the client certificate prompt is only shown during login (it will be shown when the SSL connection is set up). Moreover, in case the user has no client certificate available (e.g. when the eid is not connected), the browser must be closed and reopened for the mutual SSL to be tried again. 

# Get up and running
## Run Keycloak
```
git clone https://github.com/Mich-b/keycloak-eid
cd keycloak-eid
make run
```
## Configure your hosts file
```
<ip of docker host>	keycloak
<ip of docker host>	keycloak-eid

```
## Create a user
Browse to https://keycloak-eid:8444/auth/admin/master/console/#/realms/EIDTEST/users, cancel the client certificate authentication for now, login using admin-admin, and create a user with your SSN number (e.g. 78451278945). 

## Authenticate as that user from another Keycloak instance brokered to the keycloak-eid instance
User your e-id to authenticate using mutual TLS by opening an incognito tab and browsing to https://keycloak:8443/auth/realms/EIDTEST-NOSSL/account

=> you are now able to complete the user registration on the keycloak instance. 

# Generate keystores 
##  keycloak-eid
Generate a certificate with subject name "keycloak-eid"
```
keytool -genkey -alias keycloak-eid-ssl -keyalg RSA -keypass password -storepass password -keystore keycloak-eid/keystore.jks -ext san=dns:keycloak-eid

```
Then export this cert since we will need to trust it on the other Keycloak instance
```
keytool -exportcert -keystore keycloak-eid/keystore.jks -alias keycloak-eid-ssl -file keycloak-eid-ssl

```
## keycloak
Generate a certificate with subject name "keycloak"
```
keytool -genkey -alias keycloak-ssl -keyalg RSA -keypass password -storepass password -keystore keycloak/keystore.jks -ext san=dns:keycloak
```
Then export this cert since we will need to trust it on the other Keycloak instance
```
keytool -exportcert -keystore keycloak/keystore.jks -alias keycloak-ssl -file keycloak-ssl

```
# Generate truststores
## keycloak-eid
The keycloak-eid needs to be able to validate eid certificates. So we should trust the certs listed on https://repository.eid.belgium.be/certificates.php?cert=Root&lang=en
```
keytool -import -alias rs -file belgiumrs.crt -storetype JKS -keystore keycloak-eid/truststore.jks
keytool -import -alias keycloak-ssl -file keycloak-ssl -keystore keycloak-eid/truststore.jks
```
## keycloak
Keycloak needs to call back to keycloak-eid to exchange the code for tokens, so it needs to trust the certificate of the keycloak-eid instance. 
```
keytool -import -alias keycloak-eid -file keycloak-eid-ssl -keystore keycloak/truststore.jks

```

# References
https://www.keycloak.org/docs/6.0/server_admin/#enable-x-509-client-certificate-user-authentication
