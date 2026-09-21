# --- Stage 1: Build ---
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app

# Копируем только файлы обертки Maven и pom.xml
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Делаем скрипт mvnw исполняемым
RUN chmod +x mvnw

# Скачиваем зависимости с использованием Docker Cache (без зависающего go-offline -q)
RUN --mount=type=cache,target=/root/.m2 ./mvnw dependency:resolve

# Копируем исходники и собираем jar
COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 ./mvnw package -DskipTests

# --- Stage 2: Runtime ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Создаем безопасного не-root пользователя
RUN addgroup --system spring && adduser --system --ingroup spring spring
USER spring:spring

# Копируем собранный JAR
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]