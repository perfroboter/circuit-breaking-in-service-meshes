#!/bin/sh

install_kubectl() {
  echo "Start installing Kubectl..."
  echo "Downloading latest stable release of kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  echo "Checking Checksum"
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  if ["$(echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check)" != "kubectl: OK"]; then 
    echo "Checksum not matching. Exiting"
    exit 1
  fi
  echo "Installing kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  echo "Installation succesful: $(kubectl version --client)"
  rm kubectl && rm kubectl.sha256
}

install_minikube() {
  echo "Start installing Minkube..."
  echo "Downloading latest stable release of Minikube"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  echo "Installing Minikube"
  sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
  echo "Installation succesful: $(minikube version)"
}

install_minikube_macos() {
  echo "Start installing Minikube..."
  brew install minikube
  echo "Installation succesful: $(minikube version)"
}

install_skaffold() {
  echo "Start installing Skaffold..."
  echo "Downloading latest stable release of Skaffold"
  curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
  echo "Installing Skaffold"
  sudo install skaffold /usr/local/bin/ && rm skaffold
  echo "Installation succesful: $(skaffold version)"
}

intall_skaffold_macos() {
  echo "Start installing Skaffold..."
  echo "Downloading latest stable release of Skaffold"
  curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64 && \
  echo "Installing Skaffold"
  sudo install skaffold /usr/local/bin/
  echo "Installation succesful: $(skaffold version)"
}

start_minikube() {
  echo "Starting Minikube"
  minikube start
  echo "Connect to Minikube Docker Daemon"
  eval $(minikube docker-env)
}

setup_skaffold_for_local() {
  echo "skaffold config set --global local-cluster true"
  skaffold config set --global local-cluster true
}

install_istio() {
  # see https://istio.io/latest/docs/setup/getting-started/
  echo "Start installing Istio..."
  echo "Downloading Istio 1.13.2"
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.13.2 TARGET_ARCH=x86_64 sh -
  echo "Installing Skaffold"
  sudo install istio-1.13.2/bin/istioctl /usr/local/bin/
  echo  "Installation of istioctl succesful: $(istioctl version)"
  echo "Don't delete the downloaded folder. This folder includes samples for activating istio features and tools."
}


start_istio() {
  echo "Installing Istio with demo-configuration"
  istioctl install --set profile=demo -y
  echo  "Installation of istioctl succesful: $(istioctl version)"
  echo "Injecting Istio to the default namespace"
  kubectl label namespace default istio-injection=enabled
  echo "To activate the istio features use kubectl and yaml-Files"
}

case "$1" in
  install-kubectl)
    install_kubectl
    exit 0
    ;;
  install-minikube)
    install_minikube
    exit 0
    ;;
  install-minikube-macos)
    install_minikube_macos
    exit 0
    ;;
  install-skaffold)
    install_skaffold
    exit 0
    ;;
  intall-skaffold-macos)
    intall_skaffold_macos
    exit 0
    ;;
  start-minikube)
    start_minikube
    exit 0
    ;;
  setup-skaffold-for-local)
    setup_skaffold_for_local
    exit 0
    ;;
  install-istio)
    install_istio
    exit 0
    ;;
  start-istio)
    start_istio
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac