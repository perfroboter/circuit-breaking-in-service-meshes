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


