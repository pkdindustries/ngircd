#!/bin/bash

# generate_certs.sh
# This script generates SSL certificates and separate PEM files for ngIRCd servers.

# Set default variables
KEY_SIZE=2048
DAYS_VALID=3650  # Certificates valid for 10 years

# Create the certs directory if it doesn't exist

# Function to generate a certificate and key
generate_cert() {
    local CERT_NAME="$1"
    local KEY_FILE="${CERT_NAME}-key.pem"
    local CERT_FILE="${CERT_NAME}-cert.pem"
    local CSR_FILE="${CERT_NAME}.csr"

    echo "Generating SSL certificate for ${CERT_NAME}..."

    # Prompt for a password
    echo -n "Enter a password to protect the private key: "
    read -s PASSWORD
    echo
    echo -n "Confirm the password: "
    read -s PASSWORD_CONFIRM
    echo

    # Check if passwords match
    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo "Passwords do not match. Exiting."
        exit 1
    fi

    # Generate private key encrypted with the password
    openssl genrsa -aes256 -passout pass:"$PASSWORD" -out "$KEY_FILE" $KEY_SIZE

    # Generate certificate signing request (CSR) using the encrypted private key
    openssl req -new -key "$KEY_FILE" -passin pass:"$PASSWORD" -out "$CSR_FILE" -subj "/CN=${CERT_NAME}"

    # Generate self-signed certificate
    openssl x509 -req -in "$CSR_FILE" -passin pass:"$PASSWORD" -signkey "$KEY_FILE" -out "$CERT_FILE" -days $DAYS_VALID

    if [ ! -f dhparams.pem ]; then
        openssl dhparam -2 -out dhparams.pem 4096
    fi
    
    # Clean up
    rm "$CSR_FILE"

    # Clear the password variable
    unset PASSWORD
    unset PASSWORD_CONFIRM
}

# Main script execution
generate_cert irc

