.PHONY: all build container-build package deploy container-deploy clean

BUILD_CONTAINER := trinitronx/build-tools:centos-7
AWSCLI_CONTAINER := returnpath/awscli
REPO := returnpath/redshift-mega-maid
REV := $(shell TZ=UTC date +'%Y%m%dT%H%M%S')-$(shell git rev-parse --short HEAD)

# Load both ~/.aws and ENV variables for awscli calls so this will work
# with the full aws cli credential detection system (and allows us to run
# on local machines with ~/.aws or jenkins with ENV variables).
DOCKER_AWS_CREDENTIALS := -v ~/.aws:/root/.aws
ifdef AWS_ACCESS_KEY_ID
	DOCKER_AWS_CREDENTIALS += -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)
endif
ifdef AWS_SECRET_ACCESS_KEY
	DOCKER_AWS_CREDENTIALS += -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
endif

ifdef JENKINS_HOME
	INCLUDE_JENKINS_HOME := -e JENKINS_HOME=$(JENKINS_HOME)
endif

all: package

build: package

container-config:
	`docker run --rm $(DOCKER_AWS_CREDENTIALS) $(AWSCLI_CONTAINER) ecr get-login`
	docker pull $(BUILD_CONTAINER)

container-build: container-config
	docker run --rm $(INCLUDE_JENKINS_HOME) -v $(PWD):/opt/redshift-mega-maid -w /opt/redshift-mega-maid $(BUILD_CONTAINER) make clean build

package: Dockerfile
	docker build -t "$(REPO):$(REV)" .
	docker tag "$(REPO):$(REV)" "$(REPO):latest"

deploy: package
	`docker run --rm $(DOCKER_AWS_CREDENTIALS) returnpath/awscli ecr get-login`
	docker push $(REPO):$(REV)
	docker push $(REPO):latest
	@echo
	@echo "To manually run this container on an EC2 instance execute: "
	@echo
	@echo 'sudo docker stop mega_maid; sudo docker rm mega_maid; sudo docker run -d --name mega_maid --hostname mega_maid.$$(hostname) $(REPO):$(REV);'

container-deploy: container-config
	docker run --rm $(INCLUDE_JENKINS_HOME) --privileged -v $(PWD):/opt/redshift-mega-maid -w /opt/redshift-mega-maid $(BUILD_CONTAINER) make deploy

clean:
	rm -f tests.xml
