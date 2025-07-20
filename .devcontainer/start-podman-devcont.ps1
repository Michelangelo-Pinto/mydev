# start-devcontainer.ps1

# Avvia la podman machine se non è attiva
$machineStatus = podman machine list --format json | ConvertFrom-Json | Where-Object { $_.Name -eq "podman-machine-default" }

if ($machineStatus.Running -ne $true) {
    Write-Host "➡️ Starting podman-machine-default..."
    podman machine start
} else {
    Write-Host "✅ podman-machine-default is already running"
}

# Esporta la variabile DOCKER_HOST per la sessione corrente
$env:DOCKER_HOST = "npipe:////./pipe/docker_engine"

# Apri VS Code nella cartella corrente
Write-Host "🚀 Launching VS Code with Podman as backend..."
code .
