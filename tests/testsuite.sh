#!/bin/bash
SLEEPTIME=35

tests_none() {
  # Testrun 1: Kein Circuit-Breaker im Istio-Service-Mesh
  ./tests/testscript.sh "i-without-cb" false false
}

tests_r4j() {
  # Tests 2: Alle Tests in r4j
  cp springfactorialservice/r4j-properties/0-r4j-default.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-default" false true

  cp springfactorialservice/r4j-properties/1-r4j-consErrors.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-1" false true

  cp springfactorialservice/r4j-properties/2-r4j-timewindow.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-2" false true

  cp resilience-comparison/springfactorialservice/r4j-properties/3-r4j-avg-res-time.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-4" false true

  cp resilience-comparison/springfactorialservice/r4j-properties/4-r4j-90per-res-time.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-4" false true

  cp /home/winfo/resilience-comparison/springfactorialservice/r4j-properties/5-r4j-all-nfas.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-4" false true
}

testsuite_in_istio() {
    tests_none
    tests_r4j
    # Testrun 1: Kein Circuit-Breaker im Istio-Service-Mesh
    #./tests/testscript.sh "i-without-cb" false false
    #sleep $SLEEPTIME

    # Testrun 2: R4J-Circuit-Breaker in Istio-Mesh
    #./tests/testscript.sh "i-with-r4j-cb" false true
    #sleep $SLEEPTIME
    # Testrun 3: Mit Istio-CB Fehlererkennung
    #kubectl apply -f istio-config/springfac-cb-errors.yaml
    #sleep $SLEEPTIME
    #./tests/testscript.sh "i-without-cb-cons-errors" false false
    #kubectl delete -f istio-config/springfac-cb-errors.yaml
    #sleep $SLEEPTIME
    # Testrun 4: Mit Istio-CB Fehlererkennung
    #kubectl apply -f istio-config/springfac-cb-max-request.yaml
    #sleep $SLEEPTIME
    #./tests/testscript.sh "i-with-istio-cb-max-request" false false
    #kubectl delete -f istio-config/springfac-cb-errors.yaml
    #sleep $SLEEPTIME
}

testsuite_in_traefik() {
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
  testsuite_in_istio)
    testsuite_in_istio
    exit 0
    ;;
  testsuite_in_traefik)
    testsuite_in_traefik
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac