# syntax=docker/dockerfile:1

# ---------- Stage 1: Build ----------
FROM eclipse-temurin:25-jdk-alpine AS builder
WORKDIR /build

# Nur Build-Dateien zuerst kopieren -> Docker-Layer-Cache für Dependencies
COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle settings.gradle ./
RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon

# Quellcode erst jetzt -> Cache aus obigem Layer bleibt bei Code-Änderungen erhalten
COPY src ./src
RUN ./gradlew bootJar --no-daemon -x test

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:25-jre-alpine AS runtime

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /build/build/libs/*.jar app.jar
RUN chown appuser:appgroup app.jar

USER appuser
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]