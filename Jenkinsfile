eter_compute_repo='https://mdt.global@source.mdthink.maryland.gov/scm/et/mdt-eter-aws-core-compute.git'

pipeline {
	agent any
	
	// agent { label 'ubuntu-jenkins_py311_ans216' }

	/**
	stage ('checkoutCode') {
  		steps {
    			checkout([
				$class: 'GitSCM', 
				branches: [[name: 'master']], 
				doGenerateSubmoduleConfigurations: false, 
				extensions: [], 
				submoduleCfg: [], 
				userRemoteConfigs: [[
					credentialsId: '472b8d26-00b5-440a-b49c-f72d1cb1d798', 
					url: eter_compute_repo
				]]
			])  
		}
	}
	*/	
	stages {

		stage ('cleanWorkSpace') {
			steps { 
				cleanWs() 
			}
		}
	
		stage ('Dependencies') {
			steps {
				checkout scm
				echo 'Here is a pipeline step'
				sh 'ls -al'
			}
		}
	}
}
