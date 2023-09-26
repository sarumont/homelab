# Makefile as a command wrapper

ARTIFACTS := $(shell find . -name '*.tgz')
REPO := "https://sarumont.github.io/homelab"
CR := $(shell which cr)

all: login build tag push

include .env
export

package:
	$(CR) package .

upload:
	$(CR) upload	

cleanup:
	rm $(ARTIFACTS)

index:
	$(CR) index --charts-repo $(REPO)
