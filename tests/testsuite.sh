#!/bin/bash
SLEEPTIME=35

testrun_in_istio() {
    # Testrun 1: Kein Circuit-Breaker im Istio-Service-Mesh
    ./tests/testscript.sh "i-without-cb" false false
    sleep $SLEEPTIME
    # Testrun 2: R4J-Circuit-Breaker in Istio-Mesh
    ./tests/testscript.sh "i-with-r4j-cb" false true
    sleep $SLEEPTIME
    # Testrun 3: Mit Istio-CB Fehlererkennung
    kubectl apply -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
    ./tests/testscript.sh "i-without-cb-cons-errors" false false
    kubectl delete -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
    # Testrun 4: Mit Istio-CB Fehlererkennung
    kubectl apply -f istio-config/springfac-cb-max-request.yaml
    sleep $SLEEPTIME
    ./tests/testscript.sh "i-with-istio-cb-max-request" false false
    kubectl delete -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
}

testrun_in_traefik() {
    # Testrun 1: Kein Circuit-Breaker im Traefik-Mesh
    ./tests/testscript.sh "t-without-cb" false false
    sleep $SLEEPTIME
    # Testrun 2: R4J-Circuit-Breaker in Traefik-Mesh
    ./tests/testscript.sh "t-with-r4j-cb" false true
    sleep $SLEEPTIME
    #Testrun 3: Default-Traefik-CB
    ./tests/testscript.sh "t-with-default-traefik" true false
    sleep $SLEEPTIME
    #Testrun 3: Default-Traefik-CB
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="ResponseCodeRatio(500, 600, 0, 600) > 0.20 || LatencyAtQuantileMS(50.0) > 200"
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-with-config-traefik-cb" true false
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression-
}


case "$1" in
  testrun_in_istio)
    testrun_in_istio
    exit 0
    ;;
  testrun_in_traefik)
    testrun_in_traefik
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac