# Single VPC with HA Palo Alto Firewall with an auto-scale Web application VSI
The purpose of this pattern to deploy an auto-scale simple web application, deploy an HA Palo Alto Firewall supported by NLB/ALB in a single VPC environment.
Solution components are:
1. Single VPC
2. A public facing ALB or NLB
3. A pair of Palo Alto appliance in a HA configuration
4. A private internal facing ALB
5. An auto-scale instance group with a Web instance image for a simple web application


## Deployment procedure
1. Download a copy of terraforms:
```
git clone a copy of terraform
```
git clone https://github.com/bkoohi/vpc-ha-pa-vsi-app.git
2. Change dir to downloaded directory
```
cd vpc-ha-pa-vsi-app
```
4. update variable.tf file with the following variables:
   - Update ssh_keyname variable with your ssh key name in IBM Cloud.
      - Follow IBM Cloud procedure for creating new ssh key, if required: https://cloud.ibm.com/docs/ssh-keys?topic=ssh-keys-adding-an-ssh-key
   - Follow IBM Cloud procedure for creating new API key, if required: https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui

```
vi variable.tf
```

5. terraform init
6. terraform apply -auto-approve 
