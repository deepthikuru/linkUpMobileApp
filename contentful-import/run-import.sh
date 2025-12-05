#!/bin/bash

# Component Colors Import Script Runner
# This script helps you import all component colors into Contentful

echo "🚀 Component Colors Import Script"
echo ""
echo "Your Space ID: w44htb0sb9sl"
echo ""
echo "You need your Contentful Management API Token."
echo ""
echo "To get it:"
echo "  1. Go to Contentful → Settings (gear icon)"
echo "  2. Click 'API keys' in left sidebar"
echo "  3. Click tab 'Content management tokens'"
echo "  4. Click 'Generate personal token'"
echo "  5. Copy the token"
echo ""
echo ""

# Check if token is provided as argument
if [ -z "$1" ]; then
    echo "❌ Please provide your Management API token:"
    echo ""
    echo "Usage: ./run-import.sh YOUR_MANAGEMENT_TOKEN"
    echo ""
    echo "Or set as environment variable:"
    echo "  export CONTENTFUL_MANAGEMENT_TOKEN='your-token'"
    echo "  ./run-import.sh"
    exit 1
fi

TOKEN=$1
SPACE_ID="w44htb0sb9sl"

echo "Installing dependencies..."
npm install contentful-management

echo ""
echo "Starting import..."
echo ""

node import-component-colors.js --space-id=$SPACE_ID --token=$TOKEN

