#!/bin/bash

# Script to import with token prompt
# Usage: ./run-with-prompt.sh

echo "🚀 Contentful Import Script"
echo ""
echo "Space ID: w44htb0sb9sl"
echo ""
echo "⚠️  You need a Management API token to proceed."
echo ""
echo "To get your Management API token:"
echo "1. Go to: https://app.contentful.com/spaces/w44htb0sb9sl/settings/api-keys"
echo "2. Scroll to 'Content management tokens' section"
echo "3. Click 'Generate personal token'"
echo "4. Copy the token"
echo ""
read -p "Enter your Management API token: " TOKEN

if [ -z "$TOKEN" ]; then
  echo "❌ Error: Token is required"
  exit 1
fi

echo ""
echo "🚀 Starting import..."
echo ""

node import-all-fallback-values.js --space-id=w44htb0sb9sl --token="$TOKEN"

