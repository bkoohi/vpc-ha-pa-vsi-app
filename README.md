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
7. Identify deployed Palo Alto VSI ( pa-ha-instanca1 & pa-ha-instanca2 ) and record Floating IPs for  two Palo Alto VSIs.
```
ibmcloud login -u your_email@xx.xxx.xxxx -sso
ibmcloud target -r us-south
ibmcloud is ins
ID                                          Name                                 Status    Address      Floating IP      Profile    Image                                VPC    Zone         Resource group   
0717_71025112-088b-444a-84a1-8a669818d0b6   demo-web-instance-k9h0t676y0-2gr49   running   10.240.0.8   -                cx2-2x4    ibm-ubuntu-18-04-1-minimal-amd64-2   test   us-south-1   Default   
0717_80d015cd-af58-44db-a9e8-00379b14010c   pa-ha-instanca1                      running   10.240.1.4   52.116.133.105   bx2-8x32   test-vnf-eaf168f4                    test   us-south-1   Default   
0717_b162effd-2232-41ca-b0bb-7bbfe9fabf74   pa-ha-instanca2                      running   10.240.1.5   52.118.191.219   bx2-8x32   test-vnf-eaf168f4                    test   us-south-1   Default   
behzadkoohi@Behzads-MBP login % 
```

8. There are two Load balancer deployed in the environment. One public ALB  Load Balancer deployed for Palo Alto VSIa. One private ALB Load balancer deployed for auto scaling Web App VSIs.
```
Listing load balancers in all resource groups and region us-south under account Behzad Koohi's Account as user BEHZADK@CA.IBM.COM...
ID                                          Name           Family        Subnets                                Is public   Provision status   Operating status   Resource group   
r006-7d7d18a0-d878-4753-8ba5-0624df7a6122   test-web-alb   Application   test-web-subnet-1, test-web-subnet-2   false       active             online             Default   
r006-bb3c95ba-57ff-49ed-847f-f0606674834f   test-vnf-alb   Application   test-vnf-subnet-1                      true        active             online             Default   
behzadkoohi@Behzads-MBP login %
```
9. Identify "web-alb" application load balancer in previous step. Use ID of ALB,Run the following command to find its hostname:
```
ibmcloud is lb r006-7d7d18a0-d878-4753-8ba5-0624df7a6122 | grep Host
Host name                   7d7d18a0-us-south.lb.appdomain.cloud
```
Record hostname for the next step.

10. Using Palo Alto floaing IP and Web ALB hostname identified in previous steps, run the following script to configure the each Palo Alto instance. Script will change the default password to new_passwd provided to the script.
```
cd scripts
./remote-vnf-setup.sh 52.116.129.163 admin new_passwd 3bdeefaa-us-south.lb.appdomain.cloud ( an example )
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

