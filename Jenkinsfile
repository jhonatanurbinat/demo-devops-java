pipeline {
  agent {
    kubernetes {
      yamlFile 'build-agent.yaml'
      defaultContainer 'maven'
      idleMinutes 1
    }
  }
  stages {
    stage('Build') {
      parallel {
        stage('Compile') {
          steps {
            container('maven') {
              sh 'mvn compile'
            }
          }
        }
      }
    }
    stage('Test') {
      parallel {
        stage('Unit Tests') {
          steps {
            container('maven') {
              sh 'mvn test'
            }
          }
        }
      }
    }
    stage('SonarCloud Analysis') {
      steps {
        container('maven') {
          // Assuming you have the SonarCloud configuration in your pom.xml or you have the SONAR_TOKEN set up in Jenkins
          sh 'mvn sonar:sonar -Dsonar.projectKey=jhonatanurbinat_demo-devops-java -Dsonar.organization=jhonatanurbinat -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=ba6f0da07dd9380c7aaf144ef78be51cb2343258'
        }
      }
    }    
    stage('Package') {
      parallel {
        stage('Create Jarfile') {
          steps {
            container('maven') {
              sh 'mvn package -DskipTests'
            }
          }
        }
      stage('Docker BnP') {
        steps {
            container('kaniko') {
              sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=false --destination=docker.io/jhonatandev/devsu'
              }
            }
        }        
      }
    }
    

    stage('Deploy to Dev') {
      steps {
        // TODO
        sh "echo done"
      }
    }
  }
}
