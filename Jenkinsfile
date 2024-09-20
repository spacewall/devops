pipeline {
    agent any

    stages {
        stage('Build Docker Container') {
            steps {
                // Собираем образ
                // sh 'docker build -t hadoop .'
            }
        }

        stage('Run Tests') {
            steps {
                // Запускаем контейнер и даём 10 секунд на запуск служб
                sh 'docker run -d -p 9870:9870 --name hadoop hadoop'
                sleep(time: 5, unit: 'SECONDS')

                script {
                    // Копируем файл config в контейнер
                    sh 'docker cp config hadoop:/opt/hadoop'
                    
                    // Выполняем команду в контейнере
                    sh 'docker exec -u hadoopuser hadoop bash -c "hdfs dfs -put /opt/hadoop/config /"'
                }
            }
        }
    }

    post {
        always {
            // Останавливаем и удаляем контейнер после выполнения
            sh 'docker stop hadoop'
            sleep(time: 5, unit: 'SECONDS')
            sh 'docker rm hadoop'
        }
    }
}
