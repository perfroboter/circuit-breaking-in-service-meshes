# Vergleich von Circuit-Breaker-Implementierungen anhand eines Fallbeispiels

Studiengang: M. Sc. Wirtschaftsinformatik (in Teilzeit) an der FH Münster  
Modul: Forschungs- und Entwicklungsprojekt  
Semester: Sommersemester 2022  
Student: Lennart Potthoff  
  
Repository zum Paper "TODO Titel einfügen". Beinhaltet den prototypischen Microservice anhand dem die drei Circuit-Breaker verglichen werden: 

## Circuit-Breaker

- Java-Bibliothek Resilience4J: https://resilience4j.readme.io/docs/circuitbreaker
- Service-Mesh Istio mit Envoy-Proxy: https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/
- Service-Mesh Traefik Mesh mit Traefik-Proxy: https://doc.traefik.io/traefik-mesh/configuration/#circuit-breaker

##  Beispielservice Fakulätsservice

Der `springfactorialservice` ist ein Java/Spring-Service, der die Fakultät zu eine Zahl berechnet.
Der HTTP-Service gibt entweder die Fakultät zu einer Zahl (HttpStatus: 200) oder eine Fehlermeldung (HttpStatus: 500 / 503) zurück.



TODO: Beschreibung, der Endpunkte

## Inhalt

- `springfactorialservice` Source-Code des Beispielservices
- `fortio`: Kubernetes-Konfiguration für das Lasttest-Tool Fortio
- `istio-config`: verschiedene Konfigurationen für den Circuit-Breaker von Istio
- `traefik-config`: verschiedene Konfigurationen für den Circuit-Breaker von Traefik
- `r4j-config`: verschiedene Konfigurationen für den Circuit-Breaker von Resilience4J
- `tests`:
    - `testsuite.sh`: Skript zur Steuerungen des gesamten Testdurchlaufs:  
    Nacheinander werden die 7 Testfälle für die verschiedene Circuit-Breaker-Implementierungen und verschiedene Konfigurationen dieser aufgerufen.
    - `testscript.sh`: Eigentliches Testskript, was Fortio mit den definierten Parametern aufruft. Hierbei werden immer 7 Testfälle für verschieden Circuit-Breaker-Situationen nacheinander durchgeführt:
        - Normales Verhalten
        - Permanetene Fehler
        - Permanente Überlast
        - Transiente Fehler
        - Transiente Überlast
        - Sporadische Fehler
        - Sporadische Überlast
    - `testresults`: Ordner, wo die von Fortio erzeugten Testergebnis-JSON's abgelegt werden (Testergebnisse der durchgeführten Tests liegen hier bereits) 
    - `evaluation`:
        - `evaluation.ipynb`: Pthon-Programm (jupyter notebook) zur Aufbereitung der Testergebnisse
        - `evauluationresults`: Ordner mit den generierten Diagrammen aus der Evaluation

## Anleitung

Eine detaillierte Installations- und Bedingungsanleitung zur eigenständigen Durchführung des Tests ist hier zu finden:
- Anleitung: [ANLEITUNG.md](ANLEITUNG.md)

## Quickstart
Voraussetzung: Installation gemäß Anleitung erfolgt
```bash
# Pods/Services starten
skaffold run
# Bash in neuem Pods innerhalb des Cluster starten
kubectl run -n default -it --rm --image=buildpack-deps:stretch-curl tester /bin/bash
# Beispielhafte Aufrufe der Beispielservices
# Erfolgreiche Aufruf ohne R4J-Circuit-Breaker (Erwartetes Ergebnis: Http-Code 200, "{"result=120"}")
curl http://springfactorialservice:8080/fac-without-cb/5 -v
# Aufruf soll eine Exception innerhalb des Services auslösen (Erwartetes Ergebnis ohne Istio/Traefik-Circuit-Breaker: Http-Code 500)
curl http://springfactorialservice:8080/throw-error-without-cb/ -v
# Weitere Endpunkte mit eingeschalteten R4J-Circuit-Breaker und für den Test von transienten und sporadischen Fehler/Überlastsituationen
```

## Quellen:
Für den Aufbau dieses Repositories wurde auf die Docs der entsprechenden Technologien zurückgeriffen und Codeschnipsel aus Implementierungsbeispielen übernommen (bei größeren Codeübernahmen ist dies im Code kommentiert). Im Folgendenen eine Auflistund der entsprechenden Docs, Tutorials und Implementierungsbeispielen:
- Spring-Rest-Service-Example: https://spring.io/guides/gs/rest-service/
- Resilience4J: https://resilience4j.readme.io/docs/circuitbreaker
- Spring-Cloud-Samples Circuit Breaker: https://github.com/spring-cloud-samples/spring-cloud-circuitbreaker-demo
- Fakultätsberechnung mit BigInt:  https://stackoverflow.com/questions/891031/is-there-a-method-that-calculates-a-factorial-in-java
- Istio (Installationsanleitung und Circuit-Breaker-Konfigruation): https://istio.io/latest/docs/ 
(speziell : https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/, https://istio.io/latest/docs/reference/config/networking/destination-rule/)
- Traefik (Installationsanleitung und Circuit-Breaker-Konfigruation): https://doc.traefik.io/traefik-mesh/ (speziell: https://doc.traefik.io/traefik-mesh/configuration/#circuit-breaker, https://doc.traefik.io/traefik/v2.0/middlewares/circuitbreaker/)
- Evaluationsskript: https://docs.jupyter.org/en/latest/, https://pandas.pydata.org/docs/index.html, https://matplotlib.org/stable/index.html
- Spring-Cloud: Spring-Cloud-Starter + Spring-Cloud-Samples Circuit Breaker