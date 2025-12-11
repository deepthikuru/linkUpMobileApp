#!/bin/bash

# Script to import all fallback values to Contentful
# Usage: ./run-import-all.sh

set -e

echo "🚀 Contentful Import Script"
echo ""

# Check if space ID and token are provided
if [ -z "$CONTENTFUL_SPACE_ID" ] && [ -z "$1" ]; then
  echo "❌ Error: Missing CONTENTFUL_SPACE_ID"
  echo ""
  echo "Usage:"
  echo "  Option 1: Set environment variables"
  echo "    export CONTENTFUL_SPACE_ID=\"w44htb0sb9sl\""
  echo "    export CONTENTFUL_MANAGEMENT_TOKEN=\"your-token\""
  echo "    ./run-import-all.sh"
  echo ""
  echo "  Option 2: Pass as arguments"
  echo "    ./run-import-all.sh YOUR_MANAGEMENT_TOKEN"
  echo ""
  exit 1
fi

# Set space ID (default to known space ID)
SPACE_ID="${CONTENTFUL_SPACE_ID:-w44htb0sb9sl}"

# Get token from argument or environment
if [ -n "$1" ]; then
  TOKEN="$1"
elif [ -n "$CONTENTFUL_MANAGEMENT_TOKEN" ]; then
  TOKEN="$CONTENTFUL_MANAGEMENT_TOKEN"
else
  echo "❌ Error: Missing CONTENTFUL_MANAGEMENT_TOKEN"
  echo ""
  echo "Please provide your Management API token:"
  echo "  ./run-import-all.sh YOUR_MANAGEMENT_TOKEN"
  echo ""
  echo "Or set environment variable:"
  echo "  export CONTENTFUL_MANAGEMENT_TOKEN=\"your-token\""
  echo ""
  exit 1
fi

echo "📋 Configuration:"
echo "   Space ID: $SPACE_ID"
echo "   Token: ${TOKEN:0:20}..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
  echo ""
fi

# Run the import script
echo "🚀 Starting import..."
echo ""
node import-all-fallback-values.js --space-id="$SPACE_ID" --token="$TOKEN"

