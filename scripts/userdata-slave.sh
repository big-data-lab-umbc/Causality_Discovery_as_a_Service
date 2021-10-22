#!/bin/sh

set -e

CLUSTER_MASTER_SSH_PUB=    #id_ras.pub for master

cat ${CLUSTER_MASTER_SSH_PUB} >> ~/.ssh/authorized_keys

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

echo "PYSPARK_PYTHON=/usr/bin/python3"  >> ~/.bashrc
echo "PYSPARK_DRIVER_PYTHON=/usr/bin/python3"  >> ~/.bashrc
echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64/jre"  >> ~/.bashrc
source  ~/.bashrc
