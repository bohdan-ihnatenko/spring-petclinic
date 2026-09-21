# jdk-alpine/jre-alpine сейчас не публикуют arm64 в манифесте (падает "no
# match for platform in manifest") — у нас и сборка (раннер ARC), и рантайм
# (k3d) реально на arm64, т.к. Docker Desktop на Mac гоняет linux-VM под
# тем же arm64, без эмуляции. jammy-варианты публикуются multi-arch
# стабильно, поэтому берём их вместо alpine, а не городим --platform/QEMU.
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -q
COPY src/ src/
RUN ./mvnw package -DskipTests -q

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]