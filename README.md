# keycloak-eid
# Get up and running
## Run Keycloak
```
git clone https://github.com/Mich-b/keycloak-eid
cd keycloak-eid
make run
```

## Create a user
Browse to https://127.0.0.1:8443/auth/admin/master/console/#/create/user/EIDTEST and create a user with your SSN number (e.g. 78451278945). 

## Authenticate as that user
User your e-id to authenticate using mutual TLS by reopening your browser or by simply opening an incognito tab and browse to https://127.0.0.1:8443/auth/realms/EIDTEST/account


# Generate keystore
```
keytool -genkey -alias server-alias -keyalg RSA -keypass password -storepass password -keystore keystore.jks

```
# Generate truststore
Use the certs listed on https://repository.eid.belgium.be/certificates.php?cert=Root&lang=en
keytool -import -alias rs -file belgiumrs.crt -storetype JKS -keystore truststore.jks

# References
https://www.keycloak.org/docs/6.0/server_admin/#enable-x-509-client-certificate-user-authentication
