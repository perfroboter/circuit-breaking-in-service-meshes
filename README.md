# Resilience comparison

Vergleich der Implementierung von Timeouts, Retries und Circuit Breakern von Mircronaut, Istio etc. anhand eines simplen Prototyps

## Beispiel - Binominalkoeffizient und Fakultät

Es stehen zwei Mircroservices in diesem simplen Prototyp zur Verfügung:

1. Binominalkoeffizient-Service (`micronautnCrService`):   
Berechnet die Binominalkoeffizient aus zwei Parametern n und r (deutsch: n über k) unter Nutzung des Fakultäts-Service  
Beispiel "6 aus 49": http://localhost:8081/ncr/49/6
2. Fakultäts-Service (`micronautfactorialservice`):   
Berechnet die Fakultät zu einem übergebenen Parameter  
Beispiel: "6!": http://localhost:8080/fac/6


## Resilence-Funktionen von Micronaut
TODO


## Resilience-Funktionen von Istio

## Quellen:
- Micronaut-Client-Example: https://guides.micronaut.io/latest/micronaut-http-client-gradle-java.html
- Micronaut-Service-Example: https://guides.micronaut.io/latest/creating-your-first-micronaut-app-gradle-java.html
- https://stackoverflow.com/questions/891031/is-there-a-method-that-calculates-a-factorial-in-java

## Microservices in Kubernetes Cluster starten

Die Microservices werden mit Minikube lokal in einem Kubernetes Cluster ausgeführt. 

Vorraussetzungen: 
- Kubectl ist installiert (./manage-cluster install-kubectl)
- Minikube ist installiert (./manage-cluster install-minikube)
- Skaffold ist installiert und konfiguriert  (./manage-cluster install-skaffold && ./manage-cluster setup-skaffold-for-local )
- Istio bzw. istioctl ist installiert (./manage-cluster install-istio)

```bash
# 1. Minibube starten
./manage-cluster start-minikube
# 2. Inject istio
./mange-cluster start-istio
# 3. Microservices containerisieren und in das Kubernetes Cluster deployen
skaffold run
# 4. Test-Pod starten und curl absetzten
kubectl run -n default -it --rm --image=buildpack-deps:stretch-curl tester /bin/bash
curl http://micronautfactorialservice:8080/fac/5 #Nutzt Service-Discovery von Kubernetes
# 5. Cluster aufräumen und deployte Artefakte löschen
skaffold delete
```

# Lasttest

siehe 'load-tests'