## Download easy rsa
```
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
```

## Initialize the PKI environment (Public Key Infrastructure)
```
./easyrsa init-pki
```

## Create a new Certificate Authority (CA)
This is what our server can use to validate certificates. Locally we will use it to generate certificates.
```
./easyrsa build-ca nopass
```

## Generate the server cert and key
```
./easyrsa build-server-full server nopass
```

## Generate client config
When adding a user, generate a separate config for each user. This allows you to revoke access from the user later.

```
./easyrsa build-client-full jhall.oreilly.com nopass
```

"jhall.oreilly.com" doesn't have to be a working domain. Its a name for the client.

### If we weren't using terraform, you'd use this to import the certificate
```
aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt
```

