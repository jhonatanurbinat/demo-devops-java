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
  }  
  stages {
    stage('Deploy to Dev') {
      steps {
        script {
          // Configure AWS CLI with the provided credentials
          sh "aws configure set aws_access_key_id ${env.AWS_ACCESS_KEY_ID}"
          sh "aws configure set aws_secret_access_key ${env.AWS_SECRET_ACCESS_KEY}"
          sh "aws configure set region ${env.AWS_REGION}"

          // Update kubeconfig for EKS
          sh "aws eks update-kubeconfig --name ${env.EKS_CLUSTER_NAME} --region ${env.AWS_REGION}"

          // Now you can use kubectl to interact with your EKS cluster
          sh "kubectl get nodes"
          
          // Include your deployment commands here
          // For example, to deploy a Kubernetes deployment
          // sh "kubectl apply -f your-kubernetes-deployment-file.yaml"
        }
      }
    }    
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
    stage('Quality Gate') {
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
    


  }
}
