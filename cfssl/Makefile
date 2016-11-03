CERTS_DIR ?= tls

CERTS := $(CERTS_DIR)/myapp.local,localhost,127.0.0.1.pem

all: certs

$(CERTS_DIR):
	mkdir -p $@

check-certs:
	@for f in $(CERTS_DIR)/*.pem; do \
		openssl x509 -noout -text -in "$$f" ; \
	done

certs: $(CERTS_DIR) $(CERTS)

clean: clean-certs
	rm -Rf tls

include cfssl.mk
