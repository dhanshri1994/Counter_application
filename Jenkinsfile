final String staging_docker_host = "ssh://jenkins@172.31.88.1" 
pipeline{
    agent any
    tools { 
      maven 'mvn' 
    }
    stages{
        stage("git checkout"){
            steps{
                git branch: 'main', url: 'https://github.com/dhanshri1994/Counter_application.git'
            }
        }
        stage("unit testing"){
            steps{
                sh 'mvn test'
            }
        }
        stage("Intergration testing"){
            steps{
                sh 'mvn verify -DskipUnitTests'
            }
        }
        stage("Static Code analysis"){
            steps{
                script{
                   
                    withSonarQubeEnv(credentialsId: 'sonar') {
                     
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }
        stage("Quality gate stats"){
            steps{
                script{

                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar'
                }
            }
        }
        stage("Maven Build"){
            steps{
                sh 'mvn clean install'
            }
        }
        stage("upload file to nexus"){
            steps{
                script{
                    nexusArtifactUploader artifacts: [[artifactId: 'springboot', classifier: '', file: 'target/Uber.jar', type: 'jar']], credentialsId: 'admin-nexus', groupId: 'com.example', nexusUrl: '3.239.108.2:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'demoapp-release', version: '1.0.0'
                }
            }
        }
        stage("Docker Build"){
            steps{
                sh 'docker image build -t $JOB_NAME:v1.$BUILD_ID .'
                sh 'docker image tag $JOB_NAME:v1.$BUILD_ID dhanshri1994/$JOB_NAME:v1.$BUILD_ID'
                sh 'docker image tag $JOB_NAME:v1.$BUILD_ID dhanshri1994/$JOB_NAME:latest'
            }
        }
        stage("Push image to docker"){
            steps{
                withDockerRegistry([ credentialsId: "docker", url: "" ]) {
                    sh 'docker image push dhanshri1994/$JOB_NAME:v1.$BUILD_ID'
                    sh 'docker image push dhanshri1994/$JOB_NAME:latest'
            }
        }
    }
        stage("Deploy Stagin"){
        withEnv(["DOCKER_HOST=${staging_docker_host}"]) {
            sshagent( credentials: ['docker-host']) {
                sh "sudo docker run -d -p 80:9099 dhanshri1994/$JOB_NAME:latest"
            }
        }
    }
}
}