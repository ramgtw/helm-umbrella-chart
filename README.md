# helm-umbrella-chart
Helm Umbrella Chart for Bahmni India Distro


## Setup Developer Access to the Cluster

### Creating a User Group for EKS Cluster Admin Access

Create a new IAM group for developers
```
aws iam create-group --group-name bahmni_eks_developers
```
When IAM users are added to this group then they will get full access to resources in the EKS cluster.
### Create an IAM role
Create Role with trust policy (first time)
```
aws iam create-role --role-name BahmniEKSDeveloperRoleForIAMUsers --assume-role-policy-document file://aws/roles/BahmniEKSDeveloperRoleForIAMUsers.json
```
The next step (Put Role Policy) Adds/Updates an inline policy document that is embedded in the role created.
```
aws iam put-role-policy --role-name BahmniEKSDeveloperRoleForIAMUsers --policy-name BahmniEKSDeveloperAccess --policy-document file://aws/policies/BahmniEKSDeveloperInlinePolicy.json
```
### Create a Policy
`aws/policies` folder contains all custom policies applied to the AWS account.

Create a `AssumeRole` policy:
```
 aws iam create-policy --policy-name BahmniEKSDeveloperAssumeRolePolicy --policy-document file://aws/policies/BahmniEKSDeveloperAssumeRolePolicy.json
```
Note the policy arn 


Next, Attach the `BahmniEKSDeveloperAssumeRolePolicy` to `bahmni_eks_developers` group.
```
aws iam attach-group-policy --group-name bahmni_eks_developers --policy-arn <POLICY_ARN>
```
### Authorise kubectl with EKS
```
aws eks update-kubeconfig --name bahmni-cluster-dev
```
### Apply Kubernetes Developer Cluster Role
```
kubectl apply -f k8s-rbac/eks-developer.yaml
```
### Create Identity Mapping
```
eksctl create iamidentitymapping \
--cluster bahmni-cluster-dev \
--arn  arn:aws:iam::{YourAccountNumber}:role/BahmniEKSDeveloperRoleForIAMUsers \
--group eks-developer-group \
--username assume-role-user \
--no-duplicate-arns
```