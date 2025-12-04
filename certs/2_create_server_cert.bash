# private key ของ server (ให้ Nginx ใช้)
openssl genrsa -out server.key 2048

# CSR (certificate signing request)
openssl req -new \
  -key server.key \
  -out server.csr \
  -subj "/C=TH/ST=Bangkok/O=MyOrg/CN=localhost"

# เซ็นด้วย CA:
openssl x509 -req \
  -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt \
  -days 365 -sha256