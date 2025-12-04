# สร้าง private key ของ CA (Root CA)
openssl genrsa -out ca.key 4096

# สร้าง self-signed CA certificate (ใช้ได้ 10 ปี)
openssl req -x509 -new -nodes \
  -key ca.key \
  -sha256 -days 3650 \
  -out ca.crt \
  -subj "/C=TH/ST=Bangkok/O=MyLocalCA/CN=My Local CA"