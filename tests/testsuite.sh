#!/bin/bash
SLEEPTIME=35

tests_none() {
  # Testrun 1: Kein Circuit-Breaker im Istio-Service-Mesh
  ./tests/testscript.sh "without-cb" false false
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
  ./tests/testscript.sh "r4j-nfa-3" false true

  cp resilience-comparison/springfactorialservice/r4j-properties/4-r4j-90per-res-time.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-4" false true

  cp /home/winfo/resilience-comparison/springfactorialservice/r4j-properties/5-r4j-all-nfas.properties springfactorialservice/src/main/resources/application.properties
  skaffold delete
  skaffold run
  sleep $SLEEPTIME
  ./tests/testscript.sh "r4j-nfa-all" false true
}

tests_istio() {
    # Test 1: Istio with consErrors
    #kubectl apply -f istio-config/1-istio-consErrors.yaml
    #sleep $SLEEPTIME
    #./tests/testscript.sh "istio1-consErrors" false false
    #kubectl delete -f istio-config/1-istio-consErrors.yaml
    
    # Test 2: Istio mit Max-Requests
    #kubectl apply -f istio-config/2-istio-max-requests.yaml
    #sleep $SLEEPTIME
    #./tests/testscript.sh "istio2-maxReq" false false
    #kubectl delete -f istio-config/2-istio-max-requests.yaml

    # Test 3: Istio mit Max-Pending-Requests
    #kubectl apply -f istio-config/3-istio-max-pending-requests.yaml
    #sleep $SLEEPTIME
    #./tests/testscript.sh "istio3-maxPenReq" false false
    # kubectl delete -f istio-config/3-istio-max-pending-requests.yaml

    # Test 4: Istio mit Max-connections
    kubectl apply -f istio-config/4-istio-max-connections.yaml
    sleep $SLEEPTIME
    ./tests/testscript.sh "istio4-maxCon" false false
     kubectl delete -f istio-config/4-istio-max-connections.yaml

    # Test 5: Istio mit consErrros und Max-Requests
    kubectl apply -f istio-config/5-istio-both.yaml
    sleep $SLEEPTIME
    ./tests/testscript.sh "istio5-both" false false
    kubectl delete -f istio-config/5-istio-both.yaml   
}

testsuite_in_istio() {
    #tests_none
    #tests_r4j
    tests_istio
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
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression-
    # Testrun 1: Kein Circuit-Breaker im Traefik-Mesh
    #./tests/testscript.sh "t-without-cb" false false
    #sleep $SLEEPTIME
    # Testrun 2: R4J-Circuit-Breaker in Traefik-Mesh
    # ./tests/testscript.sh "t-with-r4j-cb" false true
    #sleep $SLEEPTIME
    #Testrun: Default-Traefik-CB
    #./tests/testscript.sh "t-with-default-traefik" true false
    #sleep $SLEEPTIME

    #Testrun: 1-cons-Errors
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="ResponseCodeRatio(500, 600, 0, 600) > 1.0" --overwrite
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-traefik-1-consErrors" true false

    #Testrun: 2-errors-duration
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="ResponseCodeRatio(500, 600, 0, 600) > 0.5" --overwrite
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-traefik-2-err-duration" true false

    #Testrun: 3-avg-res-time
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="LatencyAtQuantileMS(50.0) > 100" --overwrite
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-traefik-3-avg-res" true false

    #Testrun: 4-90-res-time
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="LatencyAtQuantileMS(90.0) > 200" --overwrite
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-traefik-4-90-res" true false

    #Testrun: 5-all
    kubectl annotate service springfactorialservice mesh.traefik.io/circuit-breaker-expression="ResponseCodeRatio(500, 600, 0, 600) > 0.5 || LatencyAtQuantileMS(50.0) > 100 || LatencyAtQuantileMS(90.0) > 200" --overwrite
    sleep $SLEEPTIME
    ./tests/testscript.sh "t-traefik-4-all" true false
}


case "$1" in
  testsuite-in-istio)
    testsuite_in_istio
    exit 0
    ;;
  testsuite-in-traefik)
    testsuite_in_traefik
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac