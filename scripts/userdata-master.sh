#!/bin/sh

set -e

#MY_PUBLIC_IP=
#MY_PRIVATE_IP=
##########TODO:ssh-keygen
CLUSTER_MASTER_IP=     #private ip
CLUSTER_SLAVES_IP=     #private ip1,ip2,ip3,...

sudo yum -y update
sudo yum -y install yum-utils
sudo yum -y groupinstall development
sudo yum list python3*
sudo yum -y install python3 python3-dev python3-pip python3-virtualenv python3-devel

sudo pip3 install --upgrade pip
sudo pip3 install numpy==1.16.2 scipy==1.2.0 pandas==0.24.1 scikit-learn==0.20.3 matplotlib networkx==1.11 cython setuptools pgmpy==0.1.6 statsmodels==0.9.0 wrapt 
sudo pip3 install --upgrade --force-reinstall setuptools

sudo amazon-linux-extras enable R3.4
sudo yum -y install R R-devel openssl-devel openssl libssh2-devel libssl-dev libcurl-devel libxml2-devel 
sudo yum -y install curl curl-devel curl-dev curl-config 
sudo echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

wget https://github.com/jakobrunge/tigramite/archive/4.1.tar.gz
tar -xf 4.1.tar.gz
cd tigramite-4.1
sudo python3 setup.py install
sudo yum -y install libcurl-devel
sudo ./install_r_packages.sh
cd

sudo Rscript -e "install.packages('MASS',dependencies = TRUE)"
sudo Rscript -e "install.packages('momentchi2',dependencies = TRUE)"
sudo Rscript -e "install.packages('devtools')"
sudo Rscript -e "library(devtools)"
sudo Rscript -e "devtools::install('external_packages/RCIT')"

sudo pip3 install rpy2==3.4.5

#########################
# update master pub key to all workers. Also cp master pub key to own authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#########################
# install hadoop (https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/)


wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
tar -xzf hadoop-3.2.1.tar.gz
mv hadoop-3.2.1 hadoop
echo "PATH=/home/ec2-user/hadoop/bin:/home/ec2-user/hadoop/sbin:$PATH"  >> ~/.profile
source ~/.profile
echo "export HADOOP_HOME=/home/ec2-user/hadoop"  >> ~/.bashrc
echo "export PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin"  >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64/jre"  >> ~/.bashrc
source  ~/.bashrc

echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64/jre" >> ~/hadoop/etc/hadoop/hadoop-env.sh
echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n<configuration>\n\t<property>\n\t\t<name>fs.default.name</name>\n\t\t<value>hdfs://${CLUSTER_MASTER_IP}:9000</value>\n\t</property>\n</configuration>' >> ~/hadoop/etc/hadoop/core-site.xml
echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n<configuration>\n\t<property>\n\t\t<name>dfs.namenode.name.dir</name>\n\t\t<value>/home/ec2-user/data/nameNode</value>\n\t</property>\n\t<property>\n\t\t<name>dfs.datanode.data.dir</name>\n\t\t<value>/home/ec2-user/data/dataNode</value>\n\t</property>\n\t<property>\n\t\t<name>dfs.replication</name>\n\t\t<value>1</value>\n\t</property>\n</configuration>' >> ~/hadoop/etc/hadoop/hdfs-site.xml
echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n<configuration>\n\t<property>\n\t\t<name>mapreduce.framework.name</name>\n\t\t<value>yarn</value>\n\t</property>\n\t<property>\n\t\t<name>yarn.app.mapreduce.am.env</name>\n\t\t<value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>\n\t</property>\n\t<property>\n\t\t<name>mapreduce.map.env</name>\n\t\t<value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>\n\t</property>\n\t<property>\n\t\t<name>mapreduce.reduce.env</name>\n\t\t<value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>\n\t</property>\n</configuration>' >> ~/hadoop/etc/hadoop/mapred-site.xml
echo -e '<?xml version="1.0" encoding="UTF-8"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n<configuration>\n\t<property>\n\t\t<name>yarn.acl.enable</name>\n\t\t<value>0</value>\n\t</property>\n\t<property>\n\t\t<name>yarn.resourcemanager.hostname</name>\n\t\t<value>${CLUSTER_MASTER_IP}</value>\n\t</property>\n\t<property>\n\t\t<name>yarn.nodemanager.aux-services</name>\n\t\t<value>mapreduce_shuffle</value>\n\t</property>\n</configuration>' >> ~/hadoop/etc/hadoop/yarn-site.xml
for IP in $(echo $CLUSTER_SLAVES_IP | sed "s/,/ /g");do
    echo '${IP}' >> ~/hadoop/etc/hadoop/workers
done

for IP in $(echo $CLUSTER_SLAVES_IP | sed "s/,/ /g");do
    scp -o "StrictHostKeyChecking no" hadoop-*.tar.gz ${IP}:/home/ec2-user
    ssh ${IP} "tar -xzf hadoop-3.2.1.tar.gz && mv hadoop-3.2.1 hadoop"
    scp ~/hadoop/etc/hadoop/* ${IP}:/home/ec2-user/hadoop/etc/hadoop/
done

# install and start spark (https://www.linode.com/docs/guides/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/, https://phoenixnap.com/kb/install-spark-on-ubuntu)
wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
tar xvf spark-*
sudo mv spark-2.4.4-bin-hadoop2.7 spark
echo "PATH=/home/ec2-user/spark/bin:/home/ec2-user/spark/sbin:$PATH" >> ~/.profile
echo "PYSPARK_PYTHON=/usr/bin/python3" >> ~/.profile
echo "PYSPARK_DRIVER_PYTHON=/usr/bin/python3" >> ~/.profile
echo "HADOOP_CONF_DIR=/home/ec2-user/hadoop/etc/hadoop" >> ~/.profile
echo "YARN_CONF_DIR=/home/ec2-user/hadoop/etc/hadoop" >> ~/.profile
echo "SPARK_HOME=/home/ec2-user/spark" >> ~/.profile
echo "LD_LIBRARY_PATH=/home/ec2-user/hadoop/lib/native:$LD_LIBRARY_PATH" >> ~/.profile
source ~/.profile

mv $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
echo "spark.master    yarn" >> $SPARK_HOME/conf/spark-defaults.conf
mv $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo "HADOOP_CONF_DIR=/home/ec2-user/hadoop/etc/hadoop" >> $SPARK_HOME/conf/spark-env.sh

# start hadoop and yarn
hdfs namenode -format
start-dfs.sh
start-yarn.sh
hdfs dfs -mkdir -p /user/ec2-user

# # test usage
# spark-submit --deploy-mode client $SPARK_HOME/examples/src/main/python/pi.py 10
# spark-submit --master yarn --deploy-mode cluster $SPARK_HOME/examples/src/main/python/pi.py 10

# git clone https://github.com/big-data-lab-umbc/ensemble_causality_learning.git
# wget https://kddworkshop.s3.us-west-2.amazonaws.com/5v_linear_1M.csv && mv 5v_linear_1M.csv ensemble_causality_learning/
# cd ensemble_causality_learning/
# hdfs dfs -put 5v_linear_1M.csv
# spark-submit --master yarn --deploy-mode cluster --conf spark.dynamicAllocation.enabled=false --num-executors 1 --executor-cores 2 --executor-memory 1g --driver-memory 3g --py-files /home/ec2-user/ensemble_causality_learning/sources.zip --files file:///home/ec2-user/ensemble_causality_learning/5v_linear_1M.csv two_phase_algorithm_data.py 3 5v_linear_1M.csv 150 3 -v
