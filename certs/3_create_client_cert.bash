# private key ของ client
openssl genrsa -out client.key 2048

# CSR ของ client
openssl req -new \
  -key client.key \
  -out client.csr \
  -subj "/C=TH/ST=Bangkok/O=MyClient/CN=test-client"

# เซ็นด้วย CA:
openssl x509 -req \
  -in client.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out client.crt \
  -days 365 -sha256