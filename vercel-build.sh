#!/bin/bash

# Create assets directory
mkdir -p assets

# Create .env file from Vercel environment variables
# Make sure to set SUPABASE_URL and SUPABASE_ANON_KEY in your Vercel project settings
echo "SUPABASE_URL=${SUPABASE_URL}" > assets/.env
echo "SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}" >> assets/.env

# Instala o Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Baixa as dependências do Flutter
flutter precache
flutter pub get

# Builda o projeto
flutter build web
