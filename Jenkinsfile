pipeline {
  agent {
    kubernetes {
      yamlFile 'build-agent.yaml'
      defaultContainer 'maven'
      idleMinutes 1
    }
  }
  environment {
    // Assuming AWS credentials are stored in Jenkins Credentials
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    // Specify your EKS Cluster Name
    EKS_CLUSTER_NAME = 'dev-cluster-2'
    // Specify your AWS Region
    AWS_REGION = 'us-east-1'
    NVD_API_KEY = credentials('nvdApiKey')
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
              //sh 'mvn test'
              sh 'mvn clean test site'
              //sh 'mvn clean test jacoco:report'
          // Generate the XML report for SonarCloud (since SonarQube 7.9+ prefers XML format)
              //sh 'mvn jacoco:report-aggregate'
            }
          }
        }
      }
    }
    stage('SCA') {
        steps {
        container('maven') {
        catchError(buildResult: 'SUCCESS', stageResult:'FAILURE') {
            //sh 'mvn org.owasp:dependency-check-maven:check -DnvdApiKey=${NVD_API_KEY} '
          }
            }
        }
        //post {
        //always {
          // archiveArtifacts allowEmptyArchive: true, artifacts: 'target/dependency-check-report.html', fingerprint: true, onlyIfSuccessful: true
          // dependencyCheckPublisher pattern: 'report.xml'
        //  }
        //}
    }
    stage('OSS License Checker') {
        steps {
        container('licensefinder') {
            sh 'ls -al'
            sh '''#!/bin/bash --login
            /bin/bash --login
            rvm use default
            gem install license_finder
            license_finder
            '''
        }
        }
    }
 
    stage('SonarCloud Analysis') {
      steps {
        container('maven') {
          script {
            // Trigger SonarCloud analysis and wait for the result
            // withSonarQubeEnv() { // YourSonarQubeEnvName should be the name you gave your SonarQube server in Jenkins' configuration
            //  sh 'mvn sonar:sonar -Dsonar.projectKey=jhonatanurbinat_demo-devops-java -Dsonar.organization=jhonatanurbinat -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=ba6f0da07dd9380c7aaf144ef78be51cb2343258'
            // }
            withCredentials([string(credentialsId: 'secretsonar', variable: 'SECRET_TEXT')]) {
              // Your pipeline steps where SECRET_TEXT is used
              withSonarQubeEnv() {
              // sh 'mvn sonar:sonar -Dsonar.projectKey=jhonatanurbinat_demo-devops-java -Dsonar.organization=jhonatanurbinat -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${SECRET_TEXT}' 
              sh 'mvn sonar:sonar -Dsonar.projectKey=jhonatanurbinat_demo-devops-java -Dsonar.organization=jhonatanurbinat -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${SECRET_TEXT} -Dsonar.coverage.jacoco.xmlReportPaths=./**/jacoco.xml'
              }
            }             
            // SonarQube Scanner step to check Quality Gate status
          }
        }
      }
    }  
    stage('Quality Gate Jacoco Coverage validation') {
      steps {
        container('maven') {
          script {
            // Trigger SonarCloud analysis and wait for the result
            // SonarQube Scanner step to check Quality Gate status
            timeout(time: 1, unit: 'HOURS') { // Adjust the timeout to your needs
              sleep(time:1, unit: 'MINUTES')
              withSonarQubeEnv() {
                def qg = waitForQualityGate() // This method returns a QualityGate object
                println qg
                if (qg.status != 'OK') {
                  error "Quality Gate failed: ${qg.status}"
                }
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

stage('Deploy to Prod') {
      steps {
          container('awscli') {
           script {
              
              sh 'aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}'
              sh 'aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}'
              sh 'aws configure set region ${AWS_REGION}' 
              sh 'aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}' 
              sh 'curl --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl'
              sh 'chmod +x /usr/local/bin/kubectl'
              sh 'kubectl get nodes' 
              sh 'ls -la' 
              sh 'kubectl apply -f manifest.yaml' 
            }            
          }  
      }
    }  

  }
}
