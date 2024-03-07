FROM maven:3.8.4-openjdk-17


WORKDIR /app

COPY .  .

RUN mvn package -DskipTests && \
    mv target/*.jar /run/demo.jar

EXPOSE 8080

CMD java  -jar /run/demo.jar
