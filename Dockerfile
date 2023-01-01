FROM openjdk:11.0
WORKDIR /app
COPY target/Uber.jar .
EXPOSE 9099
CMD ["java","-jar","Uber.jar"]
