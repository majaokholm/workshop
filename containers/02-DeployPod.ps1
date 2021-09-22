## Deploying a pod to minikube
Set-alias -Name k -Value kubectl

minikube status
##  is minikube running? - to start minikube:
# minikube start --network-plugin=cni
kubectl config current-context

#Create a namespace
$nsName = "helloworldapp"
kubectl create namespace $nsName

# option 1:
# deploy yaml directly 

kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 -n $nsName

kubectl get deployments -n $nsName
kubectl get pod,svc -n $nsName
kubectl get events -n $nsName

# expose port
kubectl expose deployment hello-node --type=LoadBalancer --port=8080 --name=hello-node-svc -n $nsName

# because we run minikube, we can make the service available this way:
# (remember to run in an admin terminal)
if ($adminProcess -eq $true) {
  $nsName = "helloworldapp"
  minikube service hello-node-svc -n $nsName
}
#option 2:
# write yaml to local drive and deploy yaml file
kubectl get pod,svc -n $nsName


# Deploy vote app:
$yml= @'
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

#lets try to write yaml file to local disk (for fun)
$yml | Out-File .\src\yaml\azure-vote.yaml # write yaml to local file
Get-Content .\src\yaml\azure-vote.yaml | select -First 5 # view first 5 lines of yaml file
# deploy yaml!
$yml | kubectl apply --namespace $nsName -f - 

# clean up: (if needed)
# kubectl delete namespace $nsName

# because we run minikube, we can make the service available this way:
if ($adminProcess -eq $true) {
  # (remember to run in an admin terminal)
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