# Causality Discovery as a Service

## Data Driven Causality Discovery as a Service on Cloud VMs via script
In ./scripts folder, we provide bash scripts for setting causality Spark cluster. 
Before running scripts, you need to setup ssh permission for your cluster. Remember fill out all parameters before running scripts.
   

## Data Driven Causality Discovery as a Service on Cloud via SDK
We provide fabfile.py with run_interface.py for running causality on AWS automatically.
  
### Prerequirement:  
Boto  
Invoke  
Paramiko  
Fabric2  

### Steps:
1. Get your own Access key and Secret key:   
Go to account -> My security credentials -> Dashboard -> rotate your access key, create new access key, download the file (accessKeys.csv).  
  
2. Get your own key pair (Or upload your own public key):  
(https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)   
Go to EC2 -> Network security -> key pairs, create key pair, download the file (your_key_pair.pem).  
Move to its path, and run 
```bash
chmod 400 your_key_pair.pem 
```
Move file to .ssh folder, and run 
```bash
mv path_to_key_pair .ssh  
```
  
3. Make a little change:  
For run_interface.py, use your key pair name to replace key_name in config. Also change other config for your experiments.  
  
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
In ./CloudFormation folder, we provide tamplates for running causality on AWS automatically. 
Start CloudFormation from: https://aws.amazon.com/cloudformation/.  
  

## Data Driven Causality Discovery as a Service on Cloud via Web Server 
In ./Webserver folder, we provide Lambda functions and steps of calling RESTful APIs for running causality on AWS automatically. 
  

