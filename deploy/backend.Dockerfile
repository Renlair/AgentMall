FROM --platform=$BUILDPLATFORM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY springboot/pom.xml ./pom.xml
COPY springboot/src ./src
COPY deploy/application.yml ./src/main/resources/application.yml
RUN --mount=type=cache,target=/root/.m2 mvn -B -ntp package

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
RUN groupadd -g 10001 app && useradd -u 10001 -g app -s /usr/sbin/nologin app && mkdir /app/files && chown app:app /app/files
COPY --from=build /build/target/springboot-0.0.1-SNAPSHOT.jar /app/app.jar
USER 10001:10001
EXPOSE 9090
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=70.0", "-XX:+ExitOnOutOfMemoryError", "-jar", "/app/app.jar"]
