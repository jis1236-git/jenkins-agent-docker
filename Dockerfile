FROM openjdk:21-alpine
WORKDIR /app
COPY . .
RUN ./gradlew build -x test
CMD ["java", "-jar", "build/libs/*.jar"]
