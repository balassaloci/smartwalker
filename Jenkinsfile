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
    stage('Build') {
      parallel {
        stage('Webpack') {
          steps {
            echo 'Webpack'
          }
        }
        stage('Backend build') {
          steps {
            echo 'Backend'
          }
        }
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
            error 'Error happened'
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
    stage('Deploy to Prod') {
      steps {
        echo 'Deploy'
      }
    }
    stage('Cleanup') {
      steps {
        echo 'Cleanup'
      }
    }
  }
}