# Large-Scale Causality Discovery Analytics as a Service
Data-driven causality discovery is a common way to understand causal relationships among different components of a system. We study how to achieve scalable data-driven causality discovery on Amazon Web Services (AWS) and Microsoft Azure cloud and propose a causality discovery as a service (CDaaS) framework. With this framework, users can easily re-run previous causality discovery experiments or run causality discovery with different setups (such as new datasets or causality discovery parameters). Our CDaaS leverages Cloud Container Registry service and Virtual Machine service to achieve scalable causality discovery with different discovery algorithms. We further did extensive experiments and benchmarking of our CDaaS to understand the effects of seven factors (big data engine parameter setting, virtual machine instance number, type, subtype, size, cloud service, cloud provider) and how to best provision cloud resources for our causality discovery service based on certain goals including execution time, budgetary cost and cost-performance ratio. We report our findings from the benchmarking, which can help obtain optimal configurations based on each application's characteristics. The findings show proper configurations could lead to both faster execution time and less budgetary cost. 

## Data Driven Causality Discovery as a Service on AWS and Azure
In ./AwsFile folder, we provide 3 client modes for executing causality Spark. In ./AwsFile folder, we provide Azure Resources Manager templates for executing causality Spark. Especially, ./scripts folder provides general scripts of any cloud VM cluster for CDaaS software environment setup.

## Data Driven Causality Discovery as a Service on AWS via LocalMachine
We provide fabfile.py with run_interface.py in ./AwsFile/LocalMachine for running causality on AWS automatically.
  
### Prerequirement:  
```bash
pip3 install boto fabric2 scanf IPython invoke
pip3 install Werkzeug --upgrade
```

### Steps:
1. Give your own configurations:   
For run_interface.py, use your key-pair name to replace "key_name" in config. Also change other configurations for your experiments.  
  
2. Start Causality Discovery Automation on AWS: 
```bash
python3 run_interface.py [access key] [secret key]  
RunCausality()  
DeleteCluster()  
```
  
3. Start Causality Discovery Step by Step: 
```bash
python3 run_interface.py [access key] [secret key]  
createCluster()  
hadoopSetting()  
prepare()  
start()  
DeleteCluster()  
```


## Data Driven Causality Discovery as a Service on AWS via CloudFormation  
In ./AwsFile/CloudFormation folder, we provide templates for running causality automatically. Please login to CloudFormation [console](https://console.aws.amazon.com/cloudformation/?pg=ln&cp=bn) for below steps.   

1. In step 1: Specify template, click Create stack -> With new resources (standard) -> Template is ready -> Upload a template file -> Upload a template file (use [CausalityAutomation.json](AwsFile/CloudFormation/CausalityAutomation.json)) -> Next. 
2. In step 2: Specify stack details, put your own Stack name and click "next". 
3. In step 3: Configure stack options, specify your Tags and Permissions, then click "next". 
4. In step 4: Review, just review all your configurations. If everything is correct, click "Create stack" at the end.  

Now CDaaS will be initialed in CloudFormation. You can directly use EC2 ssh command in Outputs.  
  
## Data Driven Causality Discovery as a Service on AWS via WebServer 
In ./AwsFile/WebServer folder, we provide Lambda functions and steps for running causality with RESTful APIs automatically. You need to create a S3 bucket named "CDaaS-object-data-storage" with public permission before start.   

Assume all resources are ready for executing Causality Discovery (if not, just follow CloudFormation steps.), here we provide two RESTful APIs, one is for POST your custom commands to start causality execution, another is for GET the causality results from public S3 bucket "CDaaS-object-data-storage".   

Please login to Lambda Function [console](https://us-west-2.console.aws.amazon.com/lambda/home?region=us-west-2) for below steps. 
1. In the Dashboard, click Create function. Select Use a blueprint, find a blueprint named "microservice-http-endpoint-python", then click Configure.
2. Write your own Function name [Function_Name], then select "Create a new role with basic Lambda permissions" in Execution role. 
3. In API Gateway trigger, select "Create an API" and select API type is "REST API", also select "open" in Security if you like. 
4. In Lambda function code, copy the code in [lambda_function.py](AwsFile/WebServer/Lambda/lambda_function.py) and replace the blueprint code. Remember to replace your credentials and instance ID in the file. Then click "Create function" at the end.

Please login to API Gateway [console](https://us-west-2.console.aws.amazon.com/apigateway/home?region=us-west-2) and find the ID of your API [API_ID] just created.   
1. You can send the POST call via command `curl -X GET https://[API_ID].execute-api.us-west-2.amazonaws.com/default/[Function_Name] -d '{"command":"cd /home/hadoop/ensemble_causality_learning && spark-submit --master yarn --deploy-mode cluster --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=public.ecr.aws/e0a3g4z6/causality-ensemble --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=hdfs:///user/hadoop/config.json --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=public.ecr.aws/e0a3g4z6/causality-ensemble --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=hdfs:///user/hadoop/config.json --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro --conf spark.dynamicAllocation.enabled=false --num-executors 8 --executor-cores 2 --executor-memory 5g --driver-memory 15g --py-files /home/hadoop/ensemble_causality_learning/sources.zip --files file:///home/hadoop/ensemble_causality_learning/5v_linear_9.5M.csv two_phase_algorithm_data.py 3 5v_linear_9.5M.csv 200 3 -v > CDaaS_result.txt && aws s3 cp CDaaS_result.txt s3://CDaaS-object-data-storage/CDaaS_result.txt"}'`.   
2. You can send the GET call via command `curl -X GET https://[API_ID].execute-api.us-west-2.amazonaws.com/default/[Function_Name] -d '{"filename":"CDaaS_result.txt"}'`.

  
## Data Driven Causality Discovery as a Service on Azure via ResourcesManager 
In ./AzureFile/CloudFormation folder, we provide ARM tamplates for running causality automatically. 
Start Tamplate Deployment from: https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-the-portal.  
