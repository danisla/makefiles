SHELL := /bin/bash

CFSSL_VERSION := R1.2

CA_NAME ?= myapp
O ?= myapp.local
COUNTRY ?= US
CITY ?= San Francisco
OU ?= mycompany
STATE ?= CA

CA_PEM ?= ca.pem
CA_KEY ?= ca-key.pem
CA_CONFIG ?= ca-config.json
CA_CSR ?= ca-csr.json

CFSSL_BIN := $(shell command -v cfssl 2> /dev/null)
cfssl:
ifndef CFSSL_BIN
	$(error cfssl not found, example install: "go get -u github.com/cloudflare/cfssl/cmd/cfssl" OR "curl -Lsf https://pkg.cfssl.org/$(CFSSL_VERSION)/cfssl_darwin-amd64 > /usr/local/bin/cfssl && chmod +x /usr/local/bin/cfssl")
endif

CFSSLJSON_BIN := $(shell command -v cfssljson 2> /dev/null)
cfssljson:
ifndef CFSSLJSON_BIN
	$(error cfssljson not found, example install: "go get -u github.com/cloudflare/cfssl/cmd/cfssljson" OR "curl -Lsf https://pkg.cfssl.org/$(CFSSL_VERSION)/cfssljson_darwin-amd64 > /usr/local/bin/cfssljson && chmod +x /usr/local/bin/cfssljson")
endif

vars:
ifndef CA_NAME
	$(error env var not defined: 'CA_NAME')
else ifndef O
	$(error env var not defined: 'O')
else ifndef COUNTRY
	$(error env var not defined: 'COUNTRY')
else ifndef CITY
	$(error env var not defined: 'CITY')
else ifndef OU
	$(error env var not defined: 'OU')
else ifndef STATE
	$(error env var not defined: 'STATE')
else ifndef CA_PEM
	$(error env var not defined: 'CA_PEM')
else ifndef CA_KEY
	$(error env var not defined: 'CA_KEY')
else ifndef CA_CONFIG
	$(error env var not defined: 'CA_CONFIG')
else ifndef CA_CSR
	$(error env var not defined: 'CA_CSR')
endif

%.pem: cfssl cfssljson $(CA_PEM)
	@if [ -e "$@" ]; then echo "ERROR: $@ already exists, not overwriting."; exit 1 ; fi ; \
	echo "INFO: Generating $@" ; \
	echo '{"CN":"$(notdir $*)","hosts":["$*"],"key":{"algo":"rsa","size":2048}}' \
    | cfssl gencert \
      -ca=$(CA_PEM) \
      -ca-key=$(CA_KEY) \
      -config=$(CA_CONFIG) \
      -profile=$(CA_NAME) \
      -hostname=$(notdir $*) - \
        | cfssljson -bare $*

$(CA_PEM): $(CA_CONFIG) $(CA_CSR)
	@if [ -e "$@" ]; then echo "ERROR: $@ already exists, not overwriting."; exit 1 ; fi ; \
	echo "INFO: Generating $@" ; \
	cfssl gencert -initca $(CA_CSR) | cfssljson -bare ca
	mv ca.pem $@
	mv ca-key.pem $(CA_KEY)
	rm ca.csr

$(CA_CONFIG):
	@if [ -e "$@" ]; then echo "ERROR: $@ already exists, not overwriting."; exit 1 ; fi ; \
	echo "INFO: Generating $@" ; \
	echo '{"signing":{"default":{"expiry":"8760h"},"profiles":{"$(CA_NAME)":{"usages":["signing","key encipherment","server auth","client auth"],"expiry":"8760h"}}}}' \
	    > $@

$(CA_CSR):
	@if [ -e "$@" ]; then echo "ERROR: $@ already exists, not overwriting."; exit 1 ; fi ; \
	echo "INFO: Generating $@" ; \
	echo '{"CN":"$(CA_NAME)","key":{"algo":"rsa","size":2048},"names":[{"C":"$(COUNTRY)","L":"$(CITY)","O":"$(O)","OU":"$(OU)","ST":"$(STATE)"}]}' \
	    > $@

clean-certs:
	rm -f $(CA_PEM) $(CA_KEY) $(CA_CSR) $(CA_CONFIG)
