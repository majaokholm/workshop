## Deploying a pod to minikube
"Below commands should be run 'one by one', try to not copy paste too much"
"Non admin commands should be executed in powershell terminal inside VS Code or ISE - use shortcut key 'F8' to run selected code"

minikube status
##  is minikube running? - to start minikube:
# minikube start --network-plugin=cni # (remember to run as ADMIN!)

# let's start with being lazy by setting "k" as alias to "kubectl"
Set-alias -Name k -Value kubectl

# Step 1 - Lets play with kubectl
##########################

# let's check if we're connected to minikube cluster
kubectl config current-context
k get node

#Create a namespace
$nsName = "helloworldapp"
kubectl create namespace $nsName

# option 1:
# deploy pod directly with kubectl commands 

kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 -n $nsName

kubectl get deployments -n $nsName
kubectl get pod,svc -n $nsName
kubectl get events -n $nsName

# expose port
kubectl expose deployment hello-node --type=LoadBalancer --port=8080 --name=hello-node-svc -n $nsName

# because we run minikube, we can make the service available this way:
## NOTE: Requires ADMIN POWERSHELL!
{
  $nsName = "helloworldapp"
  minikube service hello-node-svc -n $nsName
}
#option 2:
# write yaml to local drive and deploy yaml file
kubectl get pod,svc -n $nsName

# Step 2 - Deploy vote app:
##########################

# take a look a the YAML code inside the string variable called $yml.
# it contains multiple resources, and each resource type is split by "---"

$yml = @'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5 
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 250m
          limits:
            cpu: 500m
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
'@


$nsName = "azure-vote-app"
kubectl create namespace $nsName

#lets try to write yaml file to local disk (for fun):
$yml | Out-File .\src\yaml\azure-vote.yaml # write yaml to local file
Get-Content .\src\yaml\azure-vote.yaml | select -First 5 # view first 5 lines of yaml file

# let's deploy yaml to k8s!
# below is 2 examples of ways you can apply yaml to your cluster - remember that "kubectl apply" will create/update resources

## example 1:
# you can just | ("pipe") your yaml code into "kubectl apply"
$yml | kubectl apply --namespace $nsName -f - 
## example 2: 
# use "kubectl apply" and point to the file on the filesystem
kubectl apply -f ".\src\yaml\azure-vote.yaml" --namespace $nsName 


# because we run minikube, we can make the service available this way:
## NOTE: Requires ADMIN POWERSHELL!
{
  $nsName = "azure-vote-app"
  minikube service azure-vote-front -n $nsName

  #try openening the k8s dashboard!
  ## remember to choose "ALL NAMESPACES" instead of "default" - in the top of the screen
  minikube dashboard
}



<#
## you can try to start "k9s" to see what you have deployed - it's a terminal UI
## use arrow keys and press 0 to show all namespaces, and use keyboard to navigate
## start k9s:
k9s

# example result:


 Context: minikube                    ____  __.________         
 Cluster: minikube                   |    |/ _/   __   \______  
 User:    minikube                   |      < \____    /  ___/  
 K9s Rev: v0.24.10 ⚡v0.24.15        |    |  \   /    /\___ \   
 K8s Rev: v1.22.1                    |____|__ \ /____//____  >  
 CPU:     n/a                                \/            \/   
 MEM:     n/a                                                  
 ┌──────────────────── Deployments(all)[7] ────────────────────┐
 │ NAMESPACE↑            NAME                       READY DATE │
 │ googlesamples         web                          1/1    1 │
 │ helloworldapp         hello-node                   1/1    1 │
 │ ingress-nginx         ingress-nginx-controller     1/1    1 │
 │ ingress-traefik       traefik                      1/1    1 │
 │ kube-system           coredns                      1/1    1 │
 │ kubernetes-dashboard  dashboard-metrics-scraper    1/1    1 │
 │ kubernetes-dashboard  kubernetes-dashboard         1/1    1 │
 │                                                             │
#>

# clean up: (if needed)
kubectl delete namespace $nsName
