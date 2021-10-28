# Use Helm to deploy an Traefik ingress controller
Set-alias -Name k -Value kubectl

# try this: https://gitmemory.com/issue/Azure/AKS/974/495533524
# https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

## NOTE: Requires ADMIN POWERSHELL!
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin -eq $true) {
    Write-Host "Enabling the minikube ingress addon.."
    minikube addons enable ingress
    minikube start --network-plugin=cni
}
else {
    Write-Error "You're not running as ADMIN!"
    <#
      "execute: "
      "minikube start --network-plugin=cni"
      "minikube addons enable ingress"
    #>
}

## remember to start minikube with --network-plugin=cni and have the "ingress addon" enabled
## to check, for minikube addons:
minikube addons list # no admin required

# let's check if "nginx" is deployed now that we've enabled the addon:
kubectl get pods --namespace ingress-nginx

# lets try to use "-o" aka "--output"
kubectl get services -n ingress-nginx -o wide

kubectl get deployment --namespace ingress-nginx -o yaml # -o json # is also possible

$nsName = "testingingress"
# creating namespace..
k create namespace $nsName


$App1_appName = "app1"
$App1_appPort = "8086"
$App1_appMessage = "App 1 !"
$App1_Yml = @"
--- 
apiVersion: apps/v1
kind: Deployment
metadata: 
  labels: 
    appname: $App1_appName
  name: $App1_appName
spec: 
  selector: 
    matchLabels: 
      appName: app1
  template: 
    metadata: 
      labels: 
        appName: app1
    spec: 
      containers:
        - name: hello-world
          image: gcr.io/google-samples/node-hello:1.0
          env:
            - name: PORT
              value: "$App1_appPort"
            - name: DEMO_GREETING
              value: "$App1_appMessage"
            - name: DEMO_FAREWELL
              value: "Such a sweet sorrow"     
"@

$App2_appName = "app2"
$App2_appPort = "8087"
$App2_appMessage = "Hello from App 2 !"
$App2_Yml = @"
--- 
apiVersion: apps/v1
kind: Deployment
metadata: 
  labels: 
    appname: $App2_appName
  name: $App2_appName
spec: 
  selector: 
    matchLabels: 
      appName: app2
  template: 
    metadata: 
      labels: 
        appName: app2
    spec: 
      containers:
        - name: hello-world
          image: "gcr.io/google-samples/hello-app:2.0"
          env:
            - name: DEMO_GREETING
              value: "$App2_appMessage"
            - name: PORT
              value: "$App2_appPort"
"@

# deploy yaml and expose port
$App1_Yml | kubectl apply --namespace $nsName -f -
k expose deployment app1 --type=NodePort --port=$App1_appPort -n $nsName
k get service app1 -n $nsName

# app2:
$App2_Yml | kubectl apply --namespace $nsName -f -
k expose deployment app2 --type=NodePort --port=$App2_appPort -n $nsName
k get service app2 -n $nsName

# check deployments:
k get deployments -n $nsName

# make sure the pods are present:
k get pods -n $nsName

# because we run minikube, we can make the services available this way:
## NOTE: Requires ADMIN POWERSHELL!
{
  $nsName = "testingingress"
  minikube service app1 --url -n $nsName
  minikube service app2 --url -n $nsName
}



# now we need to apply an ingress Route

### Now, we need to setup the ingress route:
kubectl get pods -n ingress-nginx


$ingressYml = @'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - http:
        paths:
          - path: /app1
            pathType: Prefix
            backend:
              service:
                name: app1
                port:
                  number: 8086
          - path: /app2
            pathType: Prefix
            backend:
              service:
                name: app2
                port:
                  number: 8087
'@ 

$ingressYml | kubectl apply --namespace $nsName -f -

# query the route:
kubectl get ingress -n $nsName
# lets check the yaml
kubectl get ingress apps-ingress -n $nsName -o yaml


# get the IP of minikube:
minikube ip


# try to browse the IP in a browser:
"http://$(minikube ip)/app1"

<#
## example:
# http://123.123.123.123/app1 - result: 
"Hello Kubernetes!"

# http://123.123.123.123/app2 - result: 
"Hello, world!
Version: 2.0.0
Hostname: app2-68ff66d466-zkpx8"


#>