name: Build and Deploy Web App

on:
  push:
    branches: [ "main", "master" ]

permissions:
  contents: write

jobs:
  build-and-deploy:
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

    - name: Deploy to GitHub Pages
      uses: Peaceiris/actions-gh-pages@v4
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
