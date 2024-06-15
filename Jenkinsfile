
pipeline {
	agent { label 'jenkins-slave-java' }
	
	environment { 
		TF_VER = '1.8.5'
		OS_ARCH = "amd64" 
	}

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
					wget -q https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_${OS_ARCH}.zip
        			unzip -o terraform_${TF_VER}_linux_${OS_ARCH}.zip
        			sudo cp -rf terraform /usr/local/bin/
        			terraform --version

					curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
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
