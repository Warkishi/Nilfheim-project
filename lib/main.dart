name: Build and Deploy Web App

on:
  push:
    branches: [ "main", "master" ]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Java
      uses: actions/setup-java@v5
      with:
        distribution: 'zulu'
        java-version: '17'

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        channel: 'stable'

    - name: Enable Web Platform
      run: |
        flutter config --enable-web
        flutter create --platforms web .

    - name: Get Dependencies
      run: flutter pub get

    - name: Build Web
      run: flutter build web --release --base-href "/Nilfheim-project/"

    - name: Upload Pages Artifact
      uses: actions/upload-pages-artifact@v3
      with:
        path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v4
