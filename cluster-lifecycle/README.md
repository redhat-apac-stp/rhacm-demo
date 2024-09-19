# Cluster LifeCycle

ACM can provision clusters on multiple infrastructure.
We will take an example where a ficticious bank (Mario Bank) has two departments/Line of Business i.e. international remittance and retail banking. These two departments has following expectations as self service to meet there business goals:

* provision the cluster on demand
* hibernate / awake the cluster on demand to save cost
* destroy the cluster

|Business Group|infra provider|Cluster Type|Access Type|Purpose|
|---|---|---|---|--|
|international remittance|aws|3 master, 3 worker|publicly avaialble|business user acceptance testing. Here the business users are spread across the world|
|retail banking|bare metal|single node openshift|on-prem private cluster (Militarised Zone)||

## Decide the number of clusters and hubs required

Many factors will influence on the number of clusters and hubs. Mulitple clusters and hubs can be managed by Global Hub. Few factors to consider:

* Organizational context:
  * legal entities
  * geographical locations
  * infrastructure service providers
  * network security architecture
  * data residency constraints
  * operational environments
  * functional domains
  * business units
  * teams
* Technical factors:
  * fault domains (blast radius and SLA uptime)
  * differentiating performance tiers (SLO)
  * scheduled update and maintenance windows
  * resource scope (RBAC and APIs e.g., SM, ODF are global)
  * scalability limits (control plane)
* Other considerations:
  * ownership and chargeback
  * third-party vendor licensing and terms of use

## Creating cluster on aws

Let's look at the steps required to achieve it:

* Add the cloud provider credential in ACM. Here each LoB / department may have multiple accounts in AWS for there consumption.

```yml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: aws-retail-banking # give a logical name
  namespace: cloud-credentials
  labels:
    cluster.open-cluster-management.io/credentials: ""
    cluster.open-cluster-management.io/type: aws
stringData:
  aws_access_key_id: # TODO add access key
  aws_secret_access_key: # TODO add secret access key
  baseDomain: sandbox1467.opentlc.com # TODO add the base domain
  pullSecret: >
    # TODO add pull secret
  ssh-privatekey: |
    # TODO add private key
  ssh-publickey: >
    # TODO add public key
  httpProxy: ""
  httpsProxy: ""
  noProxy: ""
  additionalTrustBundle: ""
```

* admin will create managed cluster sets

```yml
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSet
metadata:
  name: international-remittance
spec:
  clusterSelector:
    selectorType: ExclusiveClusterSetLabel
```

```yml
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSet
metadata:
  name: retail-banking
spec:
  clusterSelector:
    selectorType: ExclusiveClusterSetLabel
```

* Create three users per business group ie total 6
    |Use|BU/LoB|Role|
    |---|---|---|
    |admin|platform engineering|platform owner|
    |||
    |sanjay|retail banking|owner|
    |sagar|retail banking | technical lead|
    |siddharth|retail banking | developer|
    |||
    |dilip|international remittance | owner|
    |david|international remittance | developer|
    |deepak|international remittance | technical lead|

```bash
oc create clusterrolebinding cluster-manager-admin-sanjay --clusterrole=open-cluster-management:cluster-manager-admin --user=sanjay

# sanjay can now 1) create clusters 2) import clusters 3) create clustersets [ManagedClusterSet] 4) Create Cluster pools 5) see / add credential 6) has access to `default` cluster 7) create policy, policy set
#    can't access other 1) ManagedClusterSet like retail-internet-banking and one-remittance-platform etc. 2) any other project in ocp. He has to create a new managedClusterSet to proceed.
```

```bash
oc create clusterrolebinding managedclusterset-admin-retail-sanjay --clusterrole=open-cluster-management:managedclusterset:admin:retail-banking --user=sanjay

# sanjay can now 1) create clusters 2) import clusters 3) create clustersets [ManagedClusterSet] 4) Create Cluster pools 5) ManagedClusterSet like retail-internet-banking  6) create credential in his own namespace. 7) 
#    can't access  1) see / add credential in anyother namespaces that's not accessible 2) managedClusterSet like one-remittance-platform etc. and can't create managedClusterSets 3) `default` clusterSet 4) any other project in ocp 5) create policy, policy set
```
