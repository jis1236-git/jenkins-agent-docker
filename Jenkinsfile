pipeline {
  environment {
    dockerImageName = "jis1236/simple-echo"
  }
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: kubectl
    image: alpine/k8s:1.32.3
    command:
    - sleep
    args:
    - "99d"
  - name: jnlp
    image: jis1236/jenkins-agent-docker:jdk21
    env:
    - name: DOCKER_HOST
      value: "tcp://localhost:2375"
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
'''
    }
  }
  stages {
    stage('wait for docker') {
      steps {
        sh '''
          until docker info > /dev/null 2>&1; do
            echo "Waiting for docker daemon..."
            sleep 2
          done
        '''
      }
    }
    stage('git scm update') {
      steps {
		checkout scm
      }
    }
    stage('build') {
      steps {
        sh './gradlew build -x test'
      }
    }
    stage('docker build && push') {
      steps {
        script {
          def dockerImage = docker.build(dockerImageName)
          docker.withRegistry(
            'https://index.docker.io/v1/',
            'dockerhub-credentials'
          ) {
            dockerImage.push("latest")
          }
        }
      }
    }
    stage('deploy application on kubernetes cluster') {
      steps {
        container('kubectl') {
          withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
            sh '''
              K8S_HOST=${KUBERNETES_SERVICE_HOST}
              K8S_PORT=${KUBERNETES_SERVICE_PORT}
              cp $KUBECONFIG /tmp/kubeconfig-patched
              sed -i "s|server: https://.*|server: https://${K8S_HOST}:${K8S_PORT}|g" /tmp/kubeconfig-patched
              echo "== connecting to https://${K8S_HOST}:${K8S_PORT} =="
              kubectl --kubeconfig=/tmp/kubeconfig-patched get nodes --request-timeout=5s
              kubectl --kubeconfig=/tmp/kubeconfig-patched apply -f /home/jenkins/agent/workspace/simple-echo-JenkinsFile/deployment.yaml
              kubectl --kubeconfig=/tmp/kubeconfig-patched apply -f /home/jenkins/agent/workspace/simple-echo-JenkinsFile/service.yaml
              echo "== deploy done =="
            '''
          }
        }
      }
    }
  }
  post {
    always {
      sh 'docker logout'
    }
  }
}
