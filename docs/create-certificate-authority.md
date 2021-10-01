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
```
./easyrsa build-ca nopass
```

## Generate the server cert and key
```
./easyrsa build-server-full server nopass
```

## Generate client config
"jhall.oreilly.com" doesn't have to be a working domain. Its a name for the client.

When adding a user, generate a separate config for each user. This allows you to revoke access from the user later.
```
./easyrsa build-client-full jhall.oreilly.com nopass
```

## If we weren't using terraform, you'd use this
```
aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt
```

