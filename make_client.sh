#!/bin/bash

EASY_RSA=$HOME/easy-rsa
CLIENT_DIR=$HOME/client-configs

KEY_DIR=$CLIENT_DIR/keys
OUTPUT_DIR=$CLIENT_DIR/files
BASE_CONFIG=$CLIENT_DIR/base.conf

# Генерация сертификатов клиентов
mkdir -p $KEY_DIR
mkdir -p $OUTPUT_DIR
chmod -R 700 $CLIENT_DIR
cd $EASY_RSA
./easyrsa gen-req $1 nopass
cp pki/private/$1.key $KEY_DIR
./easyrsa sign-req client $1
cp pki/issued/$1.crt ~/client-configs/keys/
sudo cp /etc/openvpn/server/ta.key $KEY_DIR
sudo cp /etc/openvpn/server/ca.crt $KEY_DIR
sudo chown www:www $KEY_DIR/*

# создание итогового файла конфигурации
cat ${BASE_CONFIG} \
	<(echo -e '<ca>') \
	${KEY_DIR}/ca.crt \
	<(echo -e '</ca>\n<cert>') \
	${KEY_DIR}/${1}.crt \
	<(echo -e '</cert>\n<key>') \
	${KEY_DIR}/${1}.key \
	<(echo -e '</key>\n<tls-crypt>') \
	${KEY_DIR}/ta.key \
	<(echo -e '</tls-crypt>') \
	> ${OUTPUT_DIR}/${1}.ovpn
