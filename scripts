#!/bin/bash
set -e

echo "⚡ Generating assets/.env from Netlify ENV VARS..."

mkdir -p assets
cat > assets/.env <<EOL
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
GOOGLE_API_KEY=$GOOGLE_API_KEY
ADMIN_EMAILS=$ADMIN_EMAILS
DRIVE_FOLDER_ID=$DRIVE_FOLDER_ID
EOL

echo "✅ .env generated successfully!"
flutter build web --release
