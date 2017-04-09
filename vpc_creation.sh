#!/bin/bash
#Sun Apr  9 17:21:07 UTC 2017
#Author ## Vishal Patil ##
#purpose : create and setup VPC for public facing

#################################################################################
#										#
#		 Do not make any changes in below code				#
#		before run this script, configure AWS cli first			#		
#										#
#################################################################################

ddate=`date +%F`

# below command will create vpc.

read -p " Enter CIDR block for your VPC e.g. 192.168.0.0/16 :- "  cidr_ip
vpc_id=`aws ec2 create-vpc --cidr-block $cidr_ip --query 'Vpc.VpcId' --output text`
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=public_$ddate


# Below command will create Internet Gateway
IG_id=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text`
aws ec2 attach-internet-gateway --internet-gateway-id $IG_id --vpc-id $vpc_id

#below command will create subnet for your VPC
read -p " Enter SUBNET for your VPC eg. 192.168.1.0/24 :- " subnet
subnet_id=`aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet --query 'Subnet.SubnetId' --output text`


# Below command will create route table
route_ID=`aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text`
aws ec2 associate-route-table --route-table-id $route_ID --subnet-id $subnet_id
aws ec2 create-route --route-table-id $route_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IG_id


# Below command will create Securit Group
read -p "Enter Name for Security Gropu e.g. public :-  " SG_name
read -p "Enter which PORT you have to open eg. SSH 22 or RDP 3389 :- " sport
read -p " Enter source/your IP address or CIDR block for allow traffic e.g 11.22.33.0/24 or any 0.0.0.0/0 :- " SCIDR
SG_ID=`aws ec2 create-security-group --group-name $SG_name --description $SG_name --vpc-id $vpc_id --query 'GroupId' --output text`
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port $sport --cidr $SCIDR

echo '############################################################################################################################'
echo " Your VPC creation completed, If you want to allow more port then allow here VPC -- > Security Group -- > Inbound Rules"
echo '############################################################################################################################'
