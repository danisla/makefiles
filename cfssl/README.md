# Makefile for self-signed TLS certs using cfssl

Generate self-signed TLS certificates with custom CA using cfssl.

## Usage

Example `Makefile`:

```
include cfssl.mk
```

```
make myapp.local,localhost,127.0.0.1.pem
```

> SANs are comma separated in the filename.

Verify:

```
openssl x509 -noout -text -in myapp.local,localhost,127.0.0.1.pem
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            7c:ed:b7:20:45:8d:ba:3a:76:06:76:7a:3b:03:65:eb:3c:27:f7:21
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=CA, L=San Francisco, O=myapp.local, OU=mycompany, CN=myapp
        Validity
            Not Before: Nov  3 22:59:00 2016 GMT
            Not After : Nov  3 22:59:00 2017 GMT
        Subject: CN=myapp.local,localhost,127.0.0.1
...
```

Generates a `myapp.local,localhost,127.0.0.1.pem` certificate and `myapp.local,localhost,127.0.0.1.pem` private key signed for DNS SANs `myapp.local` and `localhost` and IP SANs: `127.0.0.1`

Other files generated:

- `myapp.local,localhost,127.0.0.1.csr`
- `ca-config.json`
- `ca-key.pem`
- `ca.pem`
