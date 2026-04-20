FROM eclipse-temurin:21-alpine
COPY build/libs/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
