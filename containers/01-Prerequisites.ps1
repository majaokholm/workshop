## Prerequisites for workshop.
Write-host 'Code should be run "line by line", not as one full script.' -ForegroundColor Black -BackgroundColor Yellow
Write-host 'So copy code into ISE or VS Code and use F8 to run code lines, one section at the time.' -ForegroundColor Black -BackgroundColor Yellow
Return

<#
-- below code should be in an ADMIN terminal
-- So open Powershell.exe as ADMINISTRATOR (hint: CTRL+SHIFT+ENTER shortcut will open as admin)
#>

##########################
#region step 1
# Step 1 -  Install choco (a windows package manager)
##########################
## NOTE: Requires ADMIN POWERSHELL!
    If (-not (Test-Path "C:\ProgramData\chocolatey")) {
        Write-Host "Installing Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    else {
        Write-Host "Chocolatey is already installed."
    }
    
#endregion step 1
#_________________________________________________________________________#

##########################
#region step 2
# install/enable Hyper-V
##########################
## NOTE: Requires ADMIN POWERSHELL!

# 2.1: Checking if you're eligable for installing hyper-v on your laptop
systeminfo | Select-String "Hyper-V Requirements","VM Monitor Mode Extension","Virtualization Enabled","Second Level Address Translation","Data Execution Prevention Available"
<#
you can enable hyper-v if you have below result:

Hyper-V Requirements:     VM Monitor Mode Extensions: Yes
                          Virtualization Enabled In Firmware: Yes
                          Second Level Address Translation: Yes
                          Data Execution Prevention Available: Yes

# or if hyper-v is already enabled:
Hyper-V Requirements:     A hypervisor has been detected. Features required for Hyper-V will not be displayed.
#>

# 2.2: enable Hyper-V feature
Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online 
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All



# install Minikube 
## NOTE: Requires ADMIN POWERSHELL!
choco install minikube -y
choco install kubernetes-cli -y
choco install kubernetes-helm -y
choco install k9s -y

# maybe you also need the following:
## NOTE: Requires ADMIN POWERSHELL!
# - OPTIONAL!
choco install -y git
choco install -y vscode 
choco install -y azure-cli

# you can also install powershell core if you want
## NOTE: Requires ADMIN POWERSHELL!
# - OPTIONAL!
Choco install -y powershell-core

# if you want azure powershell installed:
## NOTE: Requires ADMIN POWERSHELL!
# - OPTIONAL!
Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.201 -Force | Out-Null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-null
Install-Module -Name "Az" -Scope AllUsers

#endregion step 2
#_________________________________________________________________________#



##########################
#region step 3
##########################
<#
# Step 3: Start minikube!
#>
## NOTE: Requires ADMIN POWERSHELL!
    minikube status
    minikube config set driver hyperv
    minikube start
    minikube status


# to start minikube with a specific hyper-v switch (default is just first available) - use the following:
#minikube start --vm-driver hyperv --hyperv-virtual-switch "Default Switch" --network-plugin=cni
#endregion step 3
#_________________________________________________________________________#






##########################
#region step 4
##########################
<# Step 4
-- OPTIONAL
-- if you want you can install a bunch of VS Code extensions for Azure
-- below cmds should be run inside a Windows Powershell Terminal
   (properly not as ADMIN)
#>

code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vscode.powershell
code --install-extension msazurermtools.azurerm-vscode-tools

code --install-extension ms-azure-devops.azure-pipelines
code --install-extension ms-azuretools.vscode-azureappservice     
code --install-extension ms-azuretools.vscode-azurefunctions      
code --install-extension ms-azuretools.vscode-azureresourcegroups 
code --install-extension ms-azuretools.vscode-azurestorage        
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-cosmosdb
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli

#endregion step 4
#_________________________________________________________________________#