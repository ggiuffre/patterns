FROM cirrusci/flutter:stable

# Environment setup
COPY android /patterns/android
COPY ios /patterns/ios
COPY lib /patterns/lib
COPY test /patterns/test
COPY web /patterns/web
COPY pubspec.yaml /patterns/pubspec.yaml
COPY pubspec.lock /patterns/pubspec.lock

# project setup and testing
WORKDIR /patterns
RUN flutter pub get
RUN flutter test

# web build
WORKDIR /patterns
RUN flutter config --enable-web
RUN flutter build web
