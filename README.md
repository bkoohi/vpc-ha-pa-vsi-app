# Single VPC with HA Palo Alto Firewall with an auto-scale Web application VSI
The purpose of this pattern to deploy an auto-scale simple web application, deploy an HA Palo Alto Firewall supported by NLB/ALB in a single VPC environment.
Solution components are:
1. Single VPC
2. A public facing ALB or NLB
3. A pair of Palo Alto appliance in a HA configuration
4. A private internal facing ALB
5. An auto-scale instance group with a Web instance image for a simple web application

## 1 Prerequisite 

Follow these [steps](https://github.com/bkoohi/IBM-cloud-vpc-with-vnf/edit/main/readme/prerequisite.md)
to setup your jump server or laptop with appropriate software and configurations for running terraforms to build your environment.

## 2 Deployment procedure
1. Download a copy of terraforms:
```
git clone https://github.com/bkoohi/vpc-ha-pa-vsi-app.git
```
2. Change dir to downloaded directory
```
cd vpc-ha-pa-vsi-app
```
3. Generate an API key, if you don't have a key to use for the next step
```
ibmcloud iam api-key-create newkey
Creating API key newkey under ...
OK
API key newkey was created

Please preserve the API key! It cannot be retrieved after it's created.
                 
ID            ApiKey-.....
Name          newkey   
Description      
Created At    2022-03-17T19:28+0000   
API Key       xxxxx-xxxxx
Locked        false 
```
Store xxxx-xxxx API key for the next step

4. update variable.tf file with the following variables:
```
vi variable.tf
```
   - ibmcloud_api_key: add your API key to default value
   - resource_group_name : Default is standard default resource group.
   - vpc_name : VPC name used for deployment 
   - basename : Prefix used for network subnets and VSIs name such as Demo, Dev, Prod....
   - region   : Region to use for deployment of the environment such as ca-tor, us-south
   - ssh_keyname : ssh key used for accessing Web and Palo Alto VSIs 
   - Follow IBM Cloud procedure for creating new ssh key, if required: https://cloud.ibm.com/docs/ssh-keys?topic=ssh-keys-adding-an-ssh-key


5. Initialize terrform
```
terraform init
```
6. Apply terraform
```
terraform apply -auto-approve

```
7. Review list of VSIs in VPC and identify Palo Alto VSI ( pa-ha-instanca1 & pa-ha-instanca2 ). Record FIPs for two Palo Alto VSIs.
8. Review list Load Balancers in VPC and identify Public Load Balancer ( ie. auto-scale-vpc-vnf-alb ) deployed for Palo Alto VSIs and Private Load Balanncer ( ie. auto-scale-vpc-web-alb ) deployed for auto-scale Web app VSIs. Record hostname of Private Load Balancer ( ie. 3bdeefaa-us-south.lb.appdomain.cloud )
9. Use Palo Alto configuration script provided in scripts directory to configure each Palo Alto instance
```
cd scripts
```
./remote-vnf-setup.sh 52.116.129.163 admin new_passwd 3bdeefaa-us-south.lb.appdomain.cloud ( an example )
```
10. Try step 9 for configuring 2nd Palo Alto instance
```
./remote-vnf-setup.sh 150.240.66.11 admin new_psswd 3bdeefaa-us-south.lb.appdomain.cloud ( an example )
```
11. Apply Palo Alto licenses to both appliances. Login into Devices as admin, Devices --> Licenses --> Active feature using authentication code
12. Test Web application: 

```
curl -v hostname_public_alb 
```
13. Delete the environment.

```
terraform destroy
```

14. Delete API key, if you don't need it

```
ibmcloud iam api-key-delete newkey
```

