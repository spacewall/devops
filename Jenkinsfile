pipeline {
    agent any

    stages {
        stage('Build Docker Container') {
            steps {
                // Скачиваем сборку
                sh 'curl https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz --output hadoop-3.3.6.tar.gz'

                // Собираем образ
                sh 'docker build -t hadoop .'

                // Запускаем контейнер
                sh 'docker run -d -p 9870:9870 --name hadoop hadoop'
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Копируем файл config в контейнер
                    sh 'docker cp config hadoop:/opt/hadoop'
                    sleep(time: 2, unit: 'SECONDS')
                    
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
            sleep(time: 2, unit: 'SECONDS')
            sh 'docker rm hadoop'
        }
    }
}
