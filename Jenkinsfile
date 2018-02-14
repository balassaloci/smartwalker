pipeline {
  agent any
  stages {
    stage('Docker init') {
      steps {
        echo 'Docker Init'
      }
    }
    stage('Git checkout') {
      steps {
        echo 'Git checkout'
      }
    }
    stage('Unit tests') {
      parallel {
        stage('JUnit') {
          steps {
            echo 'JUnit'
          }
        }
        stage('DBUnit') {
          steps {
            echo 'DBUnit'
          }
        }
      }
    }
    stage('UI Test') {
      parallel {
        stage('Firefox') {
          steps {
            echo 'Firefox'
          }
        }
        stage('Chrome Mobile') {
          steps {
            echo 'Chrome Mobile'
          }
        }
        stage('Chrome Desktop') {
          steps {
            echo 'Chrome Desktop'
          }
        }
        stage('Safari') {
          steps {
            echo 'Safari'
          }
        }
      }
    }
  }
}