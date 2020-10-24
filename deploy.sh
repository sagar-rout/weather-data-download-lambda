#!/bin/sh

# Author : Sagar Rout


# Setup of terraform
#echo "Setup of terraform"
#mkdir -p ~/tmp
#wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip ~/tmp
#sudo cp ~/tmp/terraform /usr/local/bin
#terraform -v

if [ -d "target" ]; then rm -Rf target; fi

mkdir -p target
pip install --target target/ -r requirements.txt
cp src/*.py target

cd target && zip -r9 ../weather_data_download.zip .

cd -

terraform apply

# clean target directory
if [ -d "target" ]; then rm -Rf target; fi