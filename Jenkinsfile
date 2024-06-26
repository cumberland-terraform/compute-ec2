pipeline {
	agent { 
		label 'jenkins-slave-java' 
	}
	
	environment { 
		TF_VER = '1.8.5'
		OS_ARCH = 'amd64' 
		EMAIL_LIST = 'grant.moore@maryland.gov,aaron.ramirez@maryland.gov'
	}

	stages {

		/*
		Check for Terraform and TFLint before install
		to reduce runtime. Print versions of each for
		documentation and pipeline debugging
		*/
		stage ('Dependencies') {
			steps {
				echo '----- Confirming Terraform is Preasent'
				sh '''
				    if ! command -V terraform &> /dev/null
					then
					    wget -q https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_${OS_ARCH}.zip
        			    unzip -o terraform_${TF_VER}_linux_${OS_ARCH}.zip
        			    sudo cp -rf terraform /usr/local/bin/
        			    terraform --version
					else
					    terraform --version
					fi
				'''
				echo '----- Confirming TFLint is Preasent'
				sh '''
				    if ! command -V tflint &> /dev/null
					then
					    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
						tflint --version
					else
					    tflint --version
					fi
				'''
				echo '----- Confirming TFSec is Preasent'
				sh '''
				    if ! command -V tfsec &> /dev/null
					then
					    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
						tfsec --version
					else
					    tfsec --version
					fi
				'''
			}
		}

		stage ('Lint') {
			steps {
				echo '----- Linting'
			}
		}

		stage ('Sec Scanning') {
		    steps {
				echo '----- Security and Misconfiguration scanning'
				sh '''
				    tfsec . --format json --no-colour --soft-fail
				'''
			}
		}

		stage ('Test') {
			steps {
				echo '---- Testing'
				sh '''
					ls -al
					terraform test --test-directory=$(pwd)/tests
				'''
			}
		}
	}

	post {
        failure {
            emailext body: 'Check console output at $BUILD_URL to view the results. \n\n ${CHANGES} \n\n -------------------------------------------------- \n${BUILD_LOG_REGEX,regex="ERROR", escapeHtml=false}',
            to:   EMAIL_LIST,
            subject: 'Build failed in Jenkins: $PROJECT_NAME - #$BUILD_NUMBER'
        }
        success {
            emailext body: 'Check console output at $BUILD_URL to view the results.  \n\n ${CHANGES} \n\n -------------------------------------------------- \n${BUILD_LOG, maxLines=100, escapeHtml=false}',
            to:   EMAIL_LIST,
            subject: 'Build succeeded in Jenkins: $PROJECT_NAME - #$BUILD_NUMBER'
        }
    }
}
