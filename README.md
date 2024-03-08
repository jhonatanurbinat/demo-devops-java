Resolucion


URL : http://aebeeeba7db6542dbbc278017000a5a7-61004271.us-east-1.elb.amazonaws.com/api/swagger-ui/index.html


Jenkins URL  http://104.155.187.220:32745/login?from=%2F   

Blue Ocean
http://104.155.187.220:32745/blue/organizations/jenkins/demo-devops-java/detail/main/40/pipeline

![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/fdb0ac64-68d7-4faa-86d1-4ef2feb1c03b)


# JENKINS GKE HELM CHARTS

Para jenkins se uso agentes en el mismo kubernetes - el Jenkins Controller es un pod de kubernetes en Google cloud Engine 

   74  helm repo add bitnami https://charts.bitnami.com/bitnami
   75  helm install my-nginx bitnami/nginx --version 15.14.0
      97  helm install --namespace ci --values jenkins.value.yaml jenkins jenkins/jenkins

Los agentes son dinamicos y usan la plantilla build-agent.yaml que tienen todo los contenedores utilitarios ( MAVEN , LICENSDFINDER , KANIKO )para hacer la compilacion 
Se usa JACOCO plugin para el test coverage 

coverage 27 por ciento y se creo un Quality gate si es menor 20 % el pipeline dara error 
![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/b9774e42-534c-47ab-991d-a2bbc8354622)



![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/eeb1b06e-47ce-4db4-8a2b-f01fa32e8479)



![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/36b0c721-9898-41a7-bcfc-5fabc0ab6d12)


Para el EKS DE AWS 

Se uso el template adjunto cloudformation1.yaml que permitio crear el bastion donde se creo el ek EKS con el comando eksctl que entrego la plantilla cloudformation2.json  que seria la segudna plantlla de EKS que se encuentra en el repositorio



![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/a7f0945b-bf65-4e50-83d8-a41db33a2e7d)


![image](https://github.com/jhonatanurbinat/demo-devops-java/assets/53740985/492b18a9-d6bd-4316-85c3-c74bae156fbe)



# Demo Devops Java

This is a simple application to be used in the technical test of DevOps.

## Getting Started

### Prerequisites

- Java Version 17
- Spring Boot 3.0.5
- Maven

### Installation

Clone this repo.

```bash
git clone https://bitbucket.org/devsu/demo-devops-java.git
```

### Database

The database is generated as a file in the main path when the project is first run, and its name is `test.mv.db`.

Consider giving access permissions to the file for proper functioning.

## Usage

To run tests you can use this command.

```bash
mvn clean test
```

To run locally the project you can use this command.

```bash
mvn spring-boot:run
```

Open http://127.0.0.1:8000/api/swagger-ui.html with your browser to see the result.

### Features

These services can perform,

#### Create User

To create a user, the endpoint **/api/users** must be consumed with the following parameters:

```bash
  Method: POST
```

```json
{
    "dni": "dni",
    "name": "name"
}
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
{
    "id": 1,
    "dni": "dni",
    "name": "name"
}
```

If the response is unsuccessful, we will receive status 400 and the following message:

```json
{
    "errors": [
        "error"
    ]
}
```

#### Get Users

To get all users, the endpoint **/api/users** must be consumed with the following parameters:

```bash
  Method: GET
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
[
    {
        "id": 1,
        "dni": "dni",
        "name": "name"
    }
]
```

#### Get User

To get an user, the endpoint **/api/users/<id>** must be consumed with the following parameters:

```bash
  Method: GET
```

If the response is successful, the service will return an HTTP Status 200 and a message with the following structure:

```json
{
    "id": 1,
    "dni": "dni",
    "name": "name"
}
```

If the user id does not exist, we will receive status 404 and the following message:

```json
{
    "errors": [
        "User not found: <id>"
    ]
}
```

If the response is unsuccessful, we will receive status 400 and the following message:

```json
{
    "errors": [
        "error"
    ]
}
```

## License

Copyright © 2023 Devsu. All rights reserved.
