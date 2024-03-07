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
          script {
            // Trigger SonarCloud analysis and wait for the result
            withSonarQubeEnv('YourSonarQubeEnvName') { // YourSonarQubeEnvName should be the name you gave your SonarQube server in Jenkins' configuration
              sh 'mvn sonar:sonar -Dsonar.projectKey=jhonatanurbinat_demo-devops-java -Dsonar.organization=jhonatanurbinat -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=ba6f0da07dd9380c7aaf144ef78be51cb2343258'
            }
            // SonarQube Scanner step to check Quality Gate status
            timeout(time: 1, unit: 'HOURS') { // Adjust the timeout to your needs
              sleep(time:1, unit: 'MINUTES')
              def qg = waitForQualityGate() // This method returns a QualityGate object
              if (qg.status != 'OK') {
                error "Quality Gate failed: ${qg.status}"
              }
            }
          }
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
