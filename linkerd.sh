#Installation
# see https://linkerd.io/2.11/getting-started/
# Step 1: Install the CLI
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/winfo/.linkerd2/bin
linkerd version
#Step 2: Validate Kubernets Cluster
linkerd check --pre
#Step 3: Install the control plane onto your cluster
linkerd install --set proxyInit.runAsRoot=true | kubectl apply -f -
linkerd check
#Step 4: Apps installieren

#Step 5: Dashboard anzeigen
linkerd viz install | kubectl apply -f - # install the on-cluster metrics stack
linkerd check
linkerd viz dashboard

#Injection of Linkerd
kubectl get -n default deploy -o yaml | linkerd inject - | kubectl apply -f -

##Notizen
# Linkerd läuft
# Blogartikelt bzgl. CircuitBreaking in Linkerd betrifft Linkerd1 und nicht Linkerd2 (komplett neu gebaut)
# Angekündigt für nächstes Release: 2.12

#Deinstallation von linkerd 
# https://linkerd.io/2.11/tasks/uninstall/
# To remove Linkerd Viz
linkerd viz uninstall | kubectl delete -f -

# To remove Control Pane

linkerd uninstall | kubectl delete -f -
