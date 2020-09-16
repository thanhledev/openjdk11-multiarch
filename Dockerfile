# Freeze with ubuntu:18.04
FROM ubuntu:18.04 as builder

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        openjdk-11-jdk-headless \
        build-essential \
        python \
        python3 \
        bzip2 \
        curl \
        zip \
        unzip \
        git && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH
ARG VERSION=master
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-$TARGETARCH"

COPY HelloWorld.java /opt/app/
WORKDIR /opt/app
RUN javac HelloWorld.java
CMD ["java", "HelloWorld"]

LABEL de.thanhledev.openjdk11.version=$VERSION \
    de.thanhledev.openjdk11.name="Ubuntu:18.04 OpenJDK11" \    
    de.thanhledev.openjdk11.vendor="Thanh Le" \
    de.thanhledev.openjdk11.architecture=$TARGETPLATFORM \
    de.thanhledev.openjdk11.vcs-ref=$VCS_REF \
    de.thanhledev.openjdk11.vcs-url=$VCS_URL \
    de.thanhledev.openjdk11.build-date=$BUILD_DATE
