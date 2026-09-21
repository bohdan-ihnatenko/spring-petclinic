FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -B

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 \
    mvn package -DskipTests -B

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

RUN groupadd -r spring && useradd -r -g spring spring
COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar
USER spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]