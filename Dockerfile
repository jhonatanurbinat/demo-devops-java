# Stage 1: Build the application
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
# Copy the project files to the container
COPY . .
# Package the application
RUN mvn package -DskipTests

# Stage 2: Create the final runtime image
FROM openjdk:17-jdk-slim
# Create a non-root user
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser
# Change to non-root user
USER appuser
# Set the working directory
WORKDIR /app
# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar /app/demo.jar
# Expose the application port
EXPOSE 8080
# Set environment variables
# ENV VARIABLE_NAME=value
# Define the health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
# Command to run the application
CMD ["java", "-jar", "/app/demo.jar"]
