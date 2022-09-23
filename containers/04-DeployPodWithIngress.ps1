
# work in progress
minikube addons enable ingress

# Verify that the Ingress controller is running
kubectl get pods -n kube-system

#Create a namespace
$nsName = "googlesamples"
kubectl create namespace $nsName


kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0 -n $nsName
kubectl expose deployment web --type=NodePort --port=8080 -n $nsName

kubectl get service web -n $nsName
minikube service web --url -n $nsName
# http://172.30.233.115:31736