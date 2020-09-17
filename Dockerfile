# Freeze with ubuntu:18.04
FROM ubuntu:18.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk11u

ARG TARGETPLATFORM
ARG VERSION=master
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN set -eux; \
    ARCH=$(echo "${TARGETPLATFORM}" | sed -e "s|.*amd64|amd64|g" -e "s|.*arm64/v8|arm64|g" -e "s|.*arm/v7|armhf|g" -e "s|.*ppc64le|ppc64le|g" -e "s|.*s390x|s390x|g"); \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='f36d7eaf1ad9f49ae255719d864b5b56d300cc57e280f65a6f42ef4ba929daf1'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-08-04-06-22/OpenJDK11U-jdk_aarch64_linux_openj9_2020-08-04-06-22.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='a1865ab6eec45f5a7183f0ef442c2fc481752a5fca12f8c4b570ce1037c835e2'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-08-04-06-22/OpenJDK11U-jdk_ppc64le_linux_openj9_2020-08-04-06-22.tar.gz'; \
         ;; \
       s390x) \
         ESUM='fe69554583cdb8c106e2bfcf0c02799fd7c22fc41d8ad43bc62e13b729c40536'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-08-04-06-22/OpenJDK11U-jdk_s390x_linux_openj9_2020-08-04-06-22.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='62fcf9b4f812dcb3eae4611b4cdea58fe53e1e0da0dd6e4238f981fe7c76cc23'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-08-04-06-22/OpenJDK11U-jdk_x64_linux_openj9_2020-08-04-06-22.tar.gz'; \
         ;; \
       arm|armhf) \
         ESUM='21c17e0f9be18d83aba775e900345bf760c4c5c8333f17e74fba850cb96a1c2e'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-08-04-06-22/OpenJDK11U-jdk_arm_linux_hotspot_2020-08-04-06-22.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    echo "${ARCH} => URL:${BINARY_URL}"; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

LABEL de.thanhledev.openjdk11.version=$VERSION \
    de.thanhledev.openjdk11.name="Ubuntu:18.04 OpenJDK11" \    
    de.thanhledev.openjdk11.vendor="Thanh Le" \
    de.thanhledev.openjdk11.architecture=$TARGETPLATFORM \
    de.thanhledev.openjdk11.vcs-ref=$VCS_REF \
    de.thanhledev.openjdk11.vcs-url=$VCS_URL \
    de.thanhledev.openjdk11.build-date=$BUILD_DATE

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"
CMD ["jshell"]
