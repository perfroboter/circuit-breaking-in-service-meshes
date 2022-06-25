FROM openjdk:11
COPY . .
RUN ./mvnw clean
RUN ./mvnw install
RUN cp target/springfactorialservice-0.0.1-SNAPSHOT.jar ./app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]