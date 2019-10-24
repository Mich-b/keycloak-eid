.phony: build run

NAMESPACE := iam
NAME := keycloak
NAMEEID := keycloak-eid
VERSION := 6.0.1

TAG := $(NAMESPACE)/$(NAME):$(VERSION)
TAGEID := $(NAMESPACE)/$(NAMEEID):$(VERSION)

build:
	@docker build -t $(TAG) -f Dockerfile-keycloak .
	@docker build -t $(TAGEID) -f Dockerfile-keycloak-eid .

remove:
	@docker stop keycloak
	@docker stop keycloak-eid
	@docker network rm mynet

#Note: contains an ugly fix using java_opts for trusting the self signed cert
run: build
	@docker network create mynet
	@docker run -d --name $(NAMEEID) --rm -it -p 8081:8080 -p 8444:8444 \
	 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin \
	 -e KEYCLOAK_IMPORT=/tmp/realm-eid.json \
	 -h $(NAMEEID) --net mynet \
	 -v $(shell pwd):/tmp \
	 $(TAGEID)

	@docker run -d --name $(NAME) --rm -it -p 8080:8080 -p 8443:8443 \
	 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin \
	 -e KEYCLOAK_IMPORT=/tmp/realm.json \
	 -h $(NAME) --net mynet \
	 -v $(shell pwd):/tmp \
	 -e JAVA_OPTS='-server -Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true -Djavax.net.ssl.trustStore=/opt/jboss/keycloak/standalone/configuration/truststore.jks' \
	 --link $(NAMEEID):$(NAMEEID) \
	 $(TAG)

reload:
	@docker exec keycloak /opt/jboss/keycloak/bin/jboss-cli.sh --connect reload
