# Use Helm to deploy an Traefik ingress controller
Set-alias -Name k -Value kubectl

# try this: https://gitmemory.com/issue/Azure/AKS/974/495533524
# https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

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
      minikube start --network-plugin=cni
      minikube addons enable ingress
    #>
}

# remember to start minikube with --network-plugin=cni
minikube start --network-plugin=cni

# let's try helm!
helm version

# add traefik repo
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

# let's see what versions of traefik are available!
helm search repo traefik/traefik --versions
helm search repo traefik/traefik --versions -o json # if you want the output in json, just add: -o json

# bonus: also valid for kubectl
$kVersion = (kubectl version -o json)
($kVersion | ConvertFrom-Json).serverVersion

# installing Helm chart
helm install -h # -h for help!
## syntax: helm install {{Deployment/Release Name}} {{Repo Name}}/{{Chart Name}}

$traefikNs = "ingress-traefik"
$traefikVersion = "10.3.2"
helm install traefik traefik/traefik `
    --version $traefikVersion `
    --namespace $traefikNs `
    --set dashboard.enabled=true `
    --create-namespace # to create the release namespace if not present

helm list --namespace $traefikNs 
<# Expected result:

NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
traefik traefik         1               2021-09-14 16:15:58.6214273 +0200 CEST  deployed        traefik-10.3.2  2.5.1
#>


k get deployments -n $traefikNs

@'
# dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: PathPrefix(`/`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
'@ | kubectl apply --namespace $traefikNs -f -
#- match: Host(`traefik.localhost`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
k get services -n $traefikNs


$traefikNs = "ingress-traefik"
minikube service traefik -n $traefikNs


helm repo add azure-samples https://azure-samples.github.io/helm-charts/


# work in progress


# nginx aka (Engine X)
# Use Helm to deploy an NGINX ingress controller
helm install stable/nginx-ingress `
    --namespace ingress-basic `
    --set controller.replicaCount=1  `
    --set controller.service.externalTrafficPolicy=Local

# installing 

