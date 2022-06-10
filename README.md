# Resilience comparison

Vergleich der Implementierung von Circuit-Breakern - Istio/Envoy und Spring/Resilience4J - anhand eines simplen Prototyps

## Beispiel: Fakultät

Es steht ein Microservice (`springfactorialservice`):
Der Service gibt entweder die Fakultät zu einer Zahl (HttpStatus: 200)oder eine Fehlermeldung (HttpStatus: 500 / 503) zurück.

Weitere Pods (werden teils auch direkt mit skaffold gestaret):
- Fortio: Lasttest-Tool
- Httpbin: Test-Webserver (simpler Http-Service)
- Deprecated: Binominalkoeffizient-Service (`micronautnCrService`)
- Deprecated: Fakultäts-Service 2 (`micronautfactorialservice`) 
- Curl-Tester: Pod, aus dem Curl-Befehle abgesetzt werden können

## Microservices in Kubernetes Cluster starten

Die Microservices werden mit Minikube lokal in einem Kubernetes Cluster ausgeführt. 

Vorraussetzungen: 
- Kubectl ist installiert (./manage-cluster install-kubectl)
- Minikube ist installiert (./manage-cluster install-minikube)
- Skaffold ist installiert und konfiguriert  (./manage-cluster install-skaffold && ./manage-cluster setup-skaffold-for-local )
- Istio bzw. istioctl ist installiert (./manage-cluster install-istio)
- Java-Services wurden einmal mit Maven gebaut (im Target-Ordner muss eine Jar liegen)

```bash
# 1. Minibube starten
./manage-cluster start-minikube
# 2. Inject istio
./mange-cluster start-istio
# 3. Microservices containerisieren und in das Kubernetes Cluster deployen
skaffold run
# 4. Test-Pod starten und curl absetzten
kubectl run -n default -it --rm --image=buildpack-deps:stretch-curl tester /bin/bash
curl http://springfactorialservice:8080/fac-without/5 
# 5. Cluster aufräumen und deployte Artefakte löschen
skaffold delete

```

## Nicht-funktionale Anforderungen 
TODO: Kopieren aus Powerpoint

## Testsuite

Es steht eine Testsuite zur Verfügung, die verschiedene Tests gegen die drei Implementierung (kein Circuit-Breaker, R4J-Circuit-Breaker und Istio-Circuit-Breaker) laufen lässt.

### Testszenarien (A-E)
- A: Normales Verhalten
- B: Permanente überlast
- C: Permanente Fehler
- D: Transiente Fehler
- E: Transiente Überlast
Details siehe  Excel-Testplan


### Testausführung
Die Testsuite lässt sich über wie folgt starten:
Voraussetzungen:
- aktueller Ordner ist Root-Pfad des Repos
- die Konstanten im Testskript sind korrekt
    - der Name des Fortio-Pods anpassen
    - die IP des Fortio-Services anpassen
    - Fortio-IP ist auch außerhalb des Clusters verfügbar (im seperaten Terminal `minikube tunnel` ausführen)

```bash
# Durchführung der gesamten Testsuite inkl. aller Szenarien
bash tests/testsuite.sh run_all
# Ausführung einzelner Szenarien
bash tests/testsuite.sh run_e
# Manelle Ausführung von Fortio
bash tests/testsuite.sh run_fortio 1 "testing-httbin" "10" "1s" "http://httpbin:8000/get"
```
### Testergebnisse
Die Testergebnisse werden vom Fortio-Pod geladen und unter `tests/testresults` als Json abgelegt.
Die Ergebnisse können auch über die Fortio-UI als Histogram betrachtet werden http://10.102.109.95:8080/fortio/browse (IP ggf. anpassen).

## Circuit-Breaker von Istio
Es gibt zwei verschiedene Konfigurationen
1. Fehler (5xx) erkennen mittels `Outlier-Detection` in `DestinationRule`  
`kubectl apply -f istio-config/springfac-cb-errors.yaml`  
2. Überlast erkennen durch `TrafficControl` in `VirtualService`  
`kubectl apply -f istio-config/springfac-cb-max-request.yaml`  
Hinweis: Diese Regel funktioniert noch nicht optimal.

## Circuit-Breaker von Spring Cloud bzw. Resilience4J
Im `springfactorialservice` ist eine Resilience4J-CB-Konfiguration aktiv. Für Details zum Aufrufe siehe Tests.

## Quellen:
- Micronaut-Client-Example: https://guides.micronaut.io/latest/micronaut-http-client-gradle-java.html
- Micronaut-Service-Example: https://guides.micronaut.io/latest/creating-your-first-micronaut-app-gradle-java.html
- https://stackoverflow.com/questions/891031/is-there-a-method-that-calculates-a-factorial-in-java
- Spring-Cloud: Spring-Cloud-Starter + Spring-Cloud-Samples Circuit Breaker