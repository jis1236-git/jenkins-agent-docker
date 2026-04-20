FROM eclipse-temurin:21-alpine

WORKDIR /app

COPY . .

RUN chmod +x gradlew
RUN ./gradlew build -x test

CMD ["java", "-jar", "build/libs/*.jar"]
