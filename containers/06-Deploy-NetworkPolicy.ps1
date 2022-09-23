# Install Calico with Kubernetes API datastore (for 50 nodes or less)
minikube status
Set-alias -Name k -Value kubectl

##  maybe you need to run: 
# minikube start --network-plugin=cni
kubectl config current-context


















Invoke-WebRequest -Uri "https://docs.projectcalico.org/manifests/calico.yaml" -OutFile ".\src\yaml\calico-manifest.yaml"
# (Invoke-WebRequest -Uri "https://docs.projectcalico.org/manifests/calico.yaml").Content
cat ".\src\yaml\calico-manifest.yaml" | select -first 10 # ('cat' and 'gc' is an alias for get-content)
kubectl apply -f ".\src\yaml\calico-manifest.yaml"


# keep an eye on:
kubectl get pods -l k8s-app=calico-node -A # "-A" is "--all-namespaces" alias
<# example:
NAMESPACE     NAME                READY   STATUS    RESTARTS   AGE
kube-system   calico-node-8rsg5   1/1     Running   0          5m
#>

## before we deploy the policy, let's deploy a new pod, so we can
## test if we can connect from this funky echoserver app
kubectl create namespace "echoserver"
kubectl create deployment "echoserver" --image=k8s.gcr.io/echoserver:1.4 -n "echoserver"
kubectl get deployment -n "echoserver"

# view IPs of pods:
kubectl get pods -A -o wide
<# example output:
NAMESPACE       NAME                                       READY   STATUS      RESTARTS   AGE     IP               NODE       NOMINATED NODE   READINESS GATES
echoserver      echoserver-75d4885d54-xb96p                1/1     Running     1          18h     10.88.0.6        minikube   <none>           <none>
helloworldapp   azure-vote-back-59d587dbb7-94lz9           1/1     Running     3          11d     10.88.0.9        minikube   <none>           <none>
helloworldapp   azure-vote-front-78dc4ff55b-7vhx6          1/1     Running     3          11d     10.88.0.7        minikube   <none>           <none>
#>

<#
- Open a new powershell windows, and execute below commands:
1. check if you're connected to minikube:
kubectl config current-context

2. Get the pod name for the deployment
$podName = (kubectl get pods -l=app="echoserver" -n "echoserver" -o name)

3. to enter a bash session on the pod
kubectl exec --stdin --tty "$podName" -n "echoserver" -- /bin/bash

4. execute try below cmd:
apt-get update && apt-get install -y iputils-ping && apt install -y net-tools

ping -c5 www.github.com
 

cat /etc/resolv.conf   # (just for fun)
# example for services: my-svc.my-namespace.svc.cluster-domain.example
 ping -c5 10.88.0.3
 ping -c5 kube-dns.kube-system.svc.cluster.local
#>


# let's deploy a standard deploy policy
kubectl apply -f ".\src\yaml\calico-default-deny-policy.yaml"

# now go back your bash terminal - and try again!
<#
 ping -c5 10.88.0.3
 ping -c5 kube-dns.kube-system.svc.cluster.local
 #>