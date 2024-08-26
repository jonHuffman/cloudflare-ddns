#!/bin/sh

# Check if required environment variables are set
if [ -z "$ZONE_ID" ] || [ -z "$RECORD_ID" ] || [ -z "$API_TOKEN" ] || [ -z "$TYPE" ] || [ -z "$DOMAIN" ] || [ -z "$PROXIED" ]; then
  echo "Error: One or more required environment variables are missing."
  exit 1
fi

# Get the current public IP address
IP=$(curl -s http://checkip.amazonaws.com)

# Validate IP retrieval
if [ -z "$IP" ]; then
  echo "Error: Could not retrieve public IP address."
  exit 1
fi

# Update the DNS record
response=$(curl -s -w "%{http_code}" -o /tmp/curl_response.txt -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
-H "Authorization: Bearer $API_TOKEN" \
-H "Content-Type: application/json" \
--data '{
  "type": "'"$TYPE"'",
  "name": "'"$DOMAIN"'",
  "content": "'"$IP"'",
  "ttl": 1,
  "proxied": '"$PROXIED"'
}')

# Check HTTP response code and handle errors
http_code=$(tail -n1 /tmp/curl_response.txt)
if [ "$http_code" -ne 200 ]; then
  echo "Error: Failed to update DNS record. HTTP status code: $http_code"
  exit 1
fi

echo "DNS record updated successfully."
