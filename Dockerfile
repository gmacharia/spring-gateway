ARG BASE_IMAGE
ARG APPLICATION_NAME
# get the base image from argument
FROM eclipse-temurin:17.0.10_7-jre-focal

WORKDIR /app

COPY . .

RUN mvn clean package package

FROM ${BASE_IMAGE}

# Add Maintainer Info
LABEL authors="gituikumacharia2@gmail.com"

# reference application name build argument
ARG APPLICATION_NAME

# App home directory
ENV APP_HOME_DIR==/apps/development

# App jar file name
ENV EXPOSE_PORT=8090

# Switch to root user
USER root

## Add Shadow Utils.
RUN yum install -y shadow-utils

# Create application folder
RUN mkdir -p ${APP_HOME_DIR}

# Create app user
RUN groupadd -g 10000 appuser
RUN useradd --home-dir ${APP_HOME_DIR} -u 10000 -g appuser appuser

# Add jar to application
COPY --from=builder /app/target/${APPLICATION_NAME}-*.jar ${APP_HOME_DIR}/application.jar


# ADD target/${APPLICATION_NAME}.jar ${APP_HOME_DIR}/application.jar
RUN echo "${APP_HOME_DIR}/application.jar"

# Grant app user the necessary rights
RUN chmod -R 0766 ${APP_HOME_DIR}
RUN chown -R appuser:appuser ${APP_HOME_DIR}
RUN chmod g+w /etc/passwd

EXPOSE ${EXPOSE_PORT}

# Switch to the application directory
WORKDIR ${APP_HOME_DIR}

# Switch to app user
USER appuser

# Entry point to run jar file
ENTRYPOINT ["java","-Dserver.port=8090","-jar","application.jar"]