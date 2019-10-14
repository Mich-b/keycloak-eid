FROM jboss/keycloak:6.0.1
COPY --chown=jboss:root truststore.jks /opt/jboss/keycloak/standalone/configuration/
COPY --chown=jboss:root keystore.jks /opt/jboss/keycloak/standalone/configuration/
COPY --chown=jboss:root standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/
