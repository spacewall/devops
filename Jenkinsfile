pipeline {
    agent any

    stages {
        stage('Build Docker Containers') {
            steps {
                // Собираем контейнеры с помощью docker-compose
                sh 'docker compose up -d --build'
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Копируем файл config в контейнер
                    sh 'docker cp config hadoop-datanode-1:/opt/hadoop'
                    sleep(time: 10, unit: 'SECONDS')
                    
                    // Выполняем команду в контейнере
                    sh 'docker exec hadoop-datanode-1 bash -c "hdfs dfs -put /opt/hadoop/config /"'
                }
            }
        }
    }

    post {
        always {
            // Останавливаем и удаляем контейнеры после выполнения
            sh 'docker-compose down'
        }
    }
}
