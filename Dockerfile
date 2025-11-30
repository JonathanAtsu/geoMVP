FROM openjdk:17-jdk-slim

EXPOSE 8087
ENV APP_HOME /usr/src/app
COPY target/*.jar $APP_HOME/app.jar
WORKDIR $APP_HOME

CMD ["java", "-jar", "app.jar"]
# Build the application JAR file before building the Docker image