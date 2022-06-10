#!/bin/bash

FORTIO_POD="fortio-deploy-7dcd84c469-nmbhj"
FORTIO_DOWNLOAD_URL="http://10.102.109.95:8080/fortio/data/"

SERVICE_URL="http://springfactorialservice:8080"
PATH_WITH_R4J_CB="/fac-with-cb/"
PATH_WITHOUT_CB="/fac-without-cb/"
PATH_FAC_WITH_CONFIG="/fac-with-config/"
PATH_THROW_ERROR_WITH_CB="/throw-error-with-cb"
PATH_THROW_EROR_WITHOUT_CB="/throw-error-without-cb"
WORKLOADS=('5' '5000' '10000' '15000' '20000' '30000')
TESTRESULT_FOLDER="tests/testresults/"
SLEEPTIME=70


print_message() {
    NC='\033[0m' # No Color
    BLUE='\033[0;34m'
    HT="#####################"
    printf "${BLUE} $HT $1 \t$HT ${NC}\n$2\n"
}

get_url_for_transient_errors() {
    #Parameter 1. isCB "true" / "false" 2. Seconds until errors 3. Duration of errors in secounds 4. WORKLOAD
    TIME_IN_MILLIS=$(($(date +%s%N)/1000000))
    TIME_FROM=$((TIME_IN_MILLIS+$1*1000))
    TIME_UNTIL=$((TIME_FROM+$2*1000))
    echo "${SERVICE_URL}${PATH_FAC_WITH_CONFIG}$4?isCB=$1&from=${TIME_FROM}&until=${TIME_UNTIL}"
}

run_test_in_fortio() {
   #Parameter: 1. Nummer, 2. Titel, 3. QPS, 4. Duration, 5. URL
   timestamp=$(date +%Y-%m-%d-%H-%M-%S)
   print_message "START TESTRUN $2" "No.: $1 Title: $2 Time: $timestamp"
   filename="$timestamp-$1-$2.json"
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename -qps $3 -t $4 -allow-initial-errors -labels "${2}" $5  >& /dev/null
   curl "${FORTIO_DOWNLOAD_URL}${filename}" -o "${TESTRESULT_FOLDER}${filename}" >& /dev/null
   echo "Json-Result saved to $filename" 
   print_message "END TESTRUN $1"
}

run_transient_test_in_fortio() {
   #Parameter: 1. Nummer, 2. Titel, 3. QPS, 4. Duration, 5. Good-URL 6. Bad-URL
   timestamp=$(date +%Y-%m-%d-%H-%M-%S)
   print_message "START TESTRUN $2" "No.: $1 Title: $2 Time: $timestamp"
   echo "Prototypische Lösung: Zusammengesetzer Test aus drei Fortio-Aufrufen (Vor, während und nach dem transienten Fehler"
   filename1="$timestamp-$1-$2-part1.json"
   filename2="$timestamp-$1-$2-part2.json"
   filename3="$timestamp-$1-$2-part3.json"
 
   #Before transient Error
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename1 -qps $3 -t $4 -allow-initial-errors -labels "${2} part1" $5  >& /dev/null
   #transient Error
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename2 -qps $3 -t $4 -allow-initial-errors -labels "${2} part2" $6  >& /dev/null
   #After transient Error
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename3 -qps $3 -t $4 -allow-initial-errors -labels "${2} part3" $5  >& /dev/null
   sleep 5
   curl "${FORTIO_DOWNLOAD_URL}${filename1}" -o "${TESTRESULT_FOLDER}${filename1}" >& /dev/null
   echo "Json-Result saved to $filename1"
   curl "${FORTIO_DOWNLOAD_URL}${filename2}" -o "${TESTRESULT_FOLDER}${filename2}" >& /dev/null
   echo "Json-Result saved to $filename2"
   curl "${FORTIO_DOWNLOAD_URL}${filename3}" -o "${TESTRESULT_FOLDER}${filename3}" >& /dev/null
   echo "Json-Result saved to $filename3"
   print_message "END TESTRUN $1"
}

testscenario_a() {
    print_message "TESTSZENARIO A: Normales Verhalten" "Normales Verhalten: keine Überlast, keine Fehler"
    run_test_in_fortio 1 "a-without-cb" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}"
    sleep $SLEEPTIME

    run_test_in_fortio 2 "a-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[1]}"
    kubectl apply -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME

    run_test_in_fortio 3 "a1-with-istio-cb-errors" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}"
    kubectl delete -f istio-config/springfac-cb-errors.yaml
    kubectl apply -f istio-config/springfac-cb-max-request.yaml
    sleep $SLEEPTIME

    run_test_in_fortio 4 "a2-with-istio-cb-max-requests" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}"
    kubectl delete -f istio-config/springfac-cb-max-request.yaml
}

testscenario_b() {
    print_message "TESTSZENARIO B: Permanente Überlast" "Permanente Überlast: konstant hoher Workload"
    run_test_in_fortio 5 "b-without-cb" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[5]}"
    sleep $SLEEPTIME

    run_test_in_fortio 6 "b-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[5]}"
    kubectl apply -f istio-config/springfac-cb-max-request.yaml
    sleep $SLEEPTIME

    run_test_in_fortio 7 "b-with-istio-cb" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[5]}"
    kubectl delete -f istio-config/springfac-cb-max-request.yaml
}

testscenario_c() {
    print_message "TESTSZENARIO C: Permanente Fehler" "Dauerhafte Fehler, keine Überlast"
    run_test_in_fortio 8 "c-without-cb" "10" "120s" "${SERVICE_URL}${PATH_THROW_EROR_WITHOUT_CB}"
    sleep $SLEEPTIME

    run_test_in_fortio 9 "c-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_THROW_ERROR_WITH_CB}"
    kubectl apply -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
    
    run_test_in_fortio 10 "c-with-istio-cb" "10" "120s" "${SERVICE_URL}${PATH_THROW_EROR_WITHOUT_CB}"
    kubectl delete -f istio-config/springfac-cb-errors.yaml
}

testscenario_d1() {
    print_message "TESTSZENARIO D: Transiente Fehler"
    echo "Umsetzung mit Endpunkt /fac-with-config/"
    run_test_in_fortio 11 "d-without-cb" "10" "120s" $(get_url_for_transient_errors "false" 40 40 ${WORKLOADS[1]})
    sleep $SLEEPTIME
    run__test_in_fortio 12 "d-with-r4j-cb" "10" "120s" $(get_url_for_transient_errors "true" 40 40 ${WORKLOADS[1]})
    kubectl apply -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
    run__test_in_fortio 13 "d-with-istio-cb" "10" "120s" $(get_url_for_transient_errors "false" 40 40 ${WORKLOADS[1]})
    kubectl delete -f istio-config/springfac-cb-errors.yaml
}

testscenario_d2() {
    print_message "TESTSZENARIO D: Transiente Fehler" ""
    echo "Prototypische Lösung: Zusammengesetzer Test"
    run_transient_test_in_fortio 11 "d-without-cb" "10" "40s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_THROW_EROR_WITHOUT_CB}"
    sleep $SLEEPTIME
    run_transient_test_in_fortio 12 "d-with-r4j-cb" "10" "40s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_THROW_ERROR_WITH_CB}"
    kubectl apply -f istio-config/springfac-cb-errors.yaml
    sleep $SLEEPTIME
    run_transient_test_in_fortio 13 "d-with-istio-cb" "10" "40s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_THROW_EROR_WITHOUT_CB}"
    kubectl delete -f istio-config/springfac-cb-errors.yaml
}

testscenario_e() {
    print_message "TESTSZENARIO E: Transiente Überlast" ""
    echo "Prototypische Lösung: Zusammengesetzer Test"
    run_transient_test_in_fortio 14 "e-without-cb" "10" "40s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[5]}"
    sleep $SLEEPTIME
    run_transient_test_in_fortio 15 "e-with-r4j-cb" "10" "40s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[5]}"
    kubectl apply -f istio-config/springfac-cb-max-request.yaml
    sleep $SLEEPTIME
    run_transient_test_in_fortio 16 "e-with-istio-cb" "10" "40s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[1]}" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[5]}"
    kubectl delete -f istio-config/springfac-cb-max-request.yaml
}

case "$1" in
  run_all)
    print_message "STARTING TESTSUITE" "Running complete testsuite"
    testscenario_a
    sleep $SLEEPTIME
    testscenario_b
    sleep $SLEEPTIME
    testscenario_c
    sleep $SLEEPTIME
    testscenario_d1
    sleep $SLEEPTIME
    testscenario_e
    sleep $SLEEPTIME
    print_message "END OF TESTSUITE" ""
    exit 0
    ;;
  run_a)
    testscenario_a
    exit 0
    ;;
  run_b)
    testscenario_b
    exit 0
    ;;
  run_c)
    testscenario_c
    exit 0
    ;;
  run_d)
    testscenario_d1
    exit 0
    ;;
  run_e)
    testscenario_e
    exit 0
    ;;
  run_fortio)
    run_test_in_fortio $2 $3 $4 $5 $6
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac