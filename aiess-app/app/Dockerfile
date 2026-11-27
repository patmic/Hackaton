# Compila la APK de AIESS en cualquier computador (Linux/Mac/Windows con Docker).
#   docker compose run --rm apk        -> deja la APK en ./dist/
# Incluye Flutter, Android SDK, NDK y CMake; compila llama.cpp (third_party/) para arm64.
FROM ghcr.io/cirruslabs/flutter:3.41.1

ENV ANDROID_NDK_VERSION=28.2.13676358
RUN yes | sdkmanager --licenses >/dev/null && \
    sdkmanager "ndk;${ANDROID_NDK_VERSION}" "cmake;3.22.1" "platforms;android-36" "build-tools;36.0.0" >/dev/null

WORKDIR /src
COPY shared ./shared
COPY third_party/llama.cpp ./third_party/llama.cpp
COPY app ./app
WORKDIR /src/app
RUN rm -f android/local.properties && flutter pub get

CMD ["bash", "-lc", "flutter build apk --release --target-platform android-arm64 && mkdir -p /out && cp build/app/outputs/flutter-apk/app-release.apk /out/AIESS.apk && echo 'APK lista en dist/AIESS.apk'"]
