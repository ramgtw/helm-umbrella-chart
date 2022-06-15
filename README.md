# helm-umbrella-chart
Helm Umbrella Chart for Bahmni India Distro


## Setup Developer Access to the Cluster

### Creating a User Group for EKS Cluster Admin Access

Create a new IAM group for develoopers
```
aws iam create-group --group-name bahmni_eks_admin
```
When IAM users are added to this group then they will get full access to resources in the EKS cluster.
### Create an IAM role
Create Role with trust policy (first time)
```
aws iam create-role --role-name BahmniEKSAdminRoleForIAMUsers --assume-role-policy-document file://aws/roles/BahmniEKSAdminRoleForIAMUsers.json
```
The next step (Put Role Policy) Adds/Updates an inline policy document that is embedded in the role created.
```
aws iam put-role-policy --role-name BahmniEKSAdminRoleForIAMUsers --policy-name BahmniEKSAdminAccess --policy-document file://aws/policies/BahmniEKSAdminInlinePolicy.json
```
### Create a Policy
`aws/policies` folder contains all custom policies applied to the AWS account.

Create a `AssumeRole` policy:
```
 aws iam create-policy --policy-name BahmniEKSAdminAssumeRolePolicy --policy-document file://aws/policies/BahmniEKSAdminAssumeRolePolicy.json
```
Note the policy arn 


Next, Attach the `BahmniEKSAdminAssumeRolePolicy` to `bahmni_eks_admin` group.
```
aws iam attach-group-policy --group-name bahmni_eks_admin --policy-arn <POLICY_ARN>
```
### Authorise kubectl with EKS
```
aws eks update-kubeconfig --name bahmni-cluster-dev
```
### Apply Kubernetes Developer Cluster Role
```
kubectl apply -f k8s-rbac/eks-admin.yaml
```
### Create Identity Mapping
```
eksctl create iamidentitymapping \
--cluster bahmni-cluster-dev \
--arn  arn:aws:iam::{YourAccountNumber}:role/BahmniEKSAdminRoleForIAMUsers \
--group system:masters \
--username assume-role-user \
--no-duplicate-arns
```