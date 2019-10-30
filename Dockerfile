FROM maven

WORKDIR /tmp/build

ADD . /tmp/build

RUN mvn clean package -DskipTests
