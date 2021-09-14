## Deploying a pod to minikube

minikube status
##  maybe you need to run: 
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
minikube service hello-node-svc

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



$yml | Out-File .\src\yaml\azure-vote.yaml # write yaml to local file
Get-Content .\src\yaml\azure-vote.yaml | select -First 5 # view first 5 lines of yaml
$yml | kubectl apply --namespace $nsName -f - # deploy yaml!

# clean up: (if needed)
# kubectl delete namespace $nsName

# because we run minikube, we can make the service available this way:
minikube service azure-vote-front

minikube dashboard