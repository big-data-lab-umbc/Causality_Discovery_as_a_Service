# Causality Discovery as a Service
Data-driven causality discovery is a common way to understand causal relationships among different components of a system. We study how to achieve scalable data-driven causality discovery on Amazon Web Services (AWS) and Microsoft Azure cloud and propose a causality discovery as a service (CDaaS) framework. With this framework, users can easily re-run previous causality discovery experiments or run causality discovery with different setups (such as new datasets or causality discovery parameters). Our CDaaS leverages Cloud Container Registry service and Virtual Machine service to achieve scalable causality discovery with different discovery algorithms. We further did extensive experiments and benchmarking of our CDaaS to understand the effects of seven factors (big data engine parameter setting, virtual machine instance number, type, subtype, size, cloud service, cloud provider) and how to best provision cloud resources for our causality discovery service based on certain goals including execution time, budgetary cost and cost-performance ratio. We report our findings from the benchmarking, which can help obtain optimal configurations based on each application's characteristics. The findings show proper configurations could lead to both faster execution time and less budgetary cost. 

## Data Driven Causality Discovery as a Service on AWS and Azure
In ./AwsFile folder, we provide 3 client modes for executing causality Spark. In ./AwsFile folder, we provide Azure Resources Manager tamplates for executing causality Spark. Especially, ./scripts folder provides general scripts of any cloud VM cluster for CDaaS software environment setup.

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
  
4. Start Causality Discovery Automation on AWS: 
```bash
python3 run_interface.py [access key] [secret key]  
RunCausality()  
DeleteCluster()  
```
  
5. Start Causality Discovery Step by Step: 
```bash
python3 run_interface.py [access key] [secret key]  
createCluster()  
hadoopSetting()  
prepare()  
start()  
DeleteCluster()  
```


## Data Driven Causality Discovery as a Service on Cloud via CloudFormation  
In ./AwsFile/CloudFormation folder, we provide tamplates for running causality automatically. 
Start CloudFormation from: https://aws.amazon.com/cloudformation/.  
  

## Data Driven Causality Discovery as a Service on Cloud via WebServer 
In ./AwsFile/WebServer folder, we provide Lambda functions and steps of calling RESTful APIs for running causality automatically. 
  
