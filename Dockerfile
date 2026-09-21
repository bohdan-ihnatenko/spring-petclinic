# syntax=docker/dockerfile:1

FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw

# --mount=type=cache держит ~/.m2 между сборками на этом же buildkit-инстансе
# (dind-сайдкар) — не тянет заново весь интернет при каждом ране.
# -B вместо -q: не заваливает лог, но и не тишина "будто зависло",
# как было с -q, когда реально пропадала сеть.
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline -B

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw package -DskipTests -B

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

RUN groupadd -r spring && useradd -r -g spring spring
COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar
USER spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]