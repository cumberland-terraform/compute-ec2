
pipeline {
	agent { label 'jenkins-slave-java' }
	
	stages {

		stage ('cleanWorkSpace') {
			steps { 
				cleanWs() 
			}
		}
	
		stage ('Dependencies') {
			steps {
				echo '----- Installing Dependencies'
				sh '''
					sudo apt-get update -y
					sudo apt-get install -y gnupg software-properties-common
					echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
						https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
						sudo tee /etc/apt/sources.list.d/hashicorp.list
					sudo apt update -y
					sudo apt-get install terraform
					curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sh
				'''
			}
		}

		stage ('Lint') {
			steps {
				echo '----- Linting'
			}
		}

		stage ('Test') {
			steps {
				echo '---- Testing'
			}
		}
	}
}
