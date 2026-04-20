FROM eclipse-temurin:21-alpine
COPY app/build/libs/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
