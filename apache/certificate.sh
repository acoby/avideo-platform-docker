#!/bin/bash

mkdir -p /etc/apache2/ssl
cd /etc/apache2/ssl

tlds=('localhost')
domains=('avideo')

subjectAltName="IP:127.0.0.1"

for tld in ${tlds[@]}; do
  subjectAltName="${subjectAltName},DNS:${tld},DNS:*.${tld}"
  for domain in ${domains[@]}; do
    subjectAltName="${subjectAltName},DNS:${domain}.${tld}";
    subjectAltName="${subjectAltName},DNS:*.${domain}.${tld}"
  done
done

CONFIG=""
CONFIG="${CONFIG}\n[ext]"
CONFIG="${CONFIG}\nbasicConstraints=critical,CA:TRUE,pathlen:0"
CONFIG="${CONFIG}\ndefault_md=sha256"
CONFIG="${CONFIG}\nkeyUsage=digitalSignature,keyCertSign,cRLSign,serverAuth"
CONFIG="${CONFIG}\n[dn]"
CONFIG="${CONFIG}\nCN=localhost"
CONFIG="${CONFIG}\n[req]"
CONFIG="${CONFIG}\ndistinguished_name=dn"
CONFIG="${CONFIG}\n[EXT]"
CONFIG="${CONFIG}\nsubjectAltName=${subjectAltName}"
CONFIG="${CONFIG}\nextendedKeyUsage=serverAuth"
CONFIG="${CONFIG}\n"
CONFIG="${CONFIG}\n"
CONFIG="${CONFIG}\n"


openssl req -x509 \
  -out localhost.crt -keyout localhost.key \
  -newkey rsa:4096 \
  -nodes \
  -sha256 \
  -days 3650 \
  -subj '/C=DE/L=Hamburg/O=acoby/OU=DEV/CN=localhost' \
  -extensions EXT -config <( \
    printf "${CONFIG}")
openssl x509 -in localhost.crt -noout -text


exit 0

echo "Create CA"
openssl req -x509 \
  -days 3650 \
  -newkey rsa:4096 \
  -nodes \
  -sha256 \
  -subj '/C=DE/L=Hamburg/O=acoby/OU=CA/CN=localhost' \
  -keyout ca.key -out ca.crt

echo "Create CSR"
openssl req \
  -out localhost.csr -keyout localhost.key \
  -newkey rsa:4096 \
  -nodes \
  -sha256 \
  -days 3650 \
  -subj '/C=DE/L=Hamburg/O=acoby/OU=DEV/CN=localhost' \
  -extensions EXT -config <( \
    printf "[dn]\nCN=localhost\n[req]\ndistinguished_name=dn\n[EXT]\nsubjectAltName=${subjectAltName}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

echo "View CSR"
openssl req -text -in localhost.csr

echo "Sign Cert"
openssl x509 \
  -req \
  -in localhost.csr \
  -days 3650 \
  -sha256 \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out localhost.crt

echo "View cert"
openssl x509 -in localhost.crt -noout -text

echo "Create PEM"
cat ca.crt > localhost.pem
cat localhost.crt >> localhost.pem

chmod 644 localhost.pem
chmod 640 localhost.key

#eof