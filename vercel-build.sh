#!/bin/bash

# Instala o Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Baixa as dependências do Flutter
flutter precache
flutter pub get

# Builda o projeto
flutter build web
