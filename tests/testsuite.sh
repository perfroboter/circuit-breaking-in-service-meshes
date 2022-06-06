#!/bin/bash

SERVICE_URL="http://springfactorialservice:8080"
PATH_WITH_R4J_CB="/fac-with-cb/"
PATH_WITHOUT_CB="/fac-without-cb/"
PATH_THROW_ERROR_WITH_CB="/throw-error"
PATH_THROW_EROR_WITHOUT_CB="/throw-error-without-cb"
WORKLOADS=('5' '5000' '10000' '15000' '20000' '30000')
FORTIO_POD="fortio-deploy-7dcd84c469-nmbhj"
FORTIO_DOWNLOAD_URL="http://10.102.109.95:8080/fortio/data/"
TESTRESULT_FOLDER="tests/testresults/"


print_message() {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    HT="#####################"
    printf "${BLUE} $HT $1 \t$HT ${NC}\n$2\n"
}

apply_istio_cb() {
    echo "IMPLEMENT ME"
}

delete_istio_cb() {
    echo "IMPLEMENT ME"
}

run_test_in_fortio() {
   #Parameter: 1. Nummer, 2. Titel, 3. QPS, 4. Duration, 5. URL
   timestamp=$(date +%Y-%m-%d-%H-%M-%S)
   print_message "START TESTRUN $1" "No.: $1 Title: $2 Time: $timestamp"
   filename="$timestamp-$1-$2.json"
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename -qps $3 -t $4 -allow-initial-errors $5  >& /dev/null
   curl "${FORTIO_DOWNLOAD_URL}${filename}" -o "${TESTRESULT_FOLDER}${filename}" >& /dev/null
   echo "Json-Result saved to $filename" 
   print_message "END TESTRUN $1"
}


print_message "STARTING TESTSUITE" "Aktuelle Istio-Konfiguration (Destinationrule):"
kubectl get destinationrule


print_message "TESTSZENARIO A: Normal" "Normales Verhalten: keine Überlast, keine Fehler"
run_test_in_fortio 1 "a-without-cb" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[2]}"
sleep 70
run_test_in_fortio 2 "a-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[2]}"
sleep 70
# Istio konfigurieren
# Istio testen

print_message "TESTSZENARIO B: Permanente Überlast" "Permanente Überlast: konstant hoher Workload"
run_test_in_fortio 3 "b-without-cb" "10" "120s" "${SERVICE_URL}${PATH_WITHOUT_CB}${WORKLOADS[5]}"
sleep 70
run_test_in_fortio 4 "b-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_WITH_R4J_CB}${WORKLOADS[5]}"
sleep 70
# Istio konfigurieren
# Istio testen

print_message "TESTSZENARIO C: Permanente Fehler" "Dauerhafte Fehler, keine Überlast"
run_test_in_fortio 5 "c-without-cb" "10" "120s" "${SERVICE_URL}${PATH_THROW_EROR_WITHOUT_CB}"
sleep 70
run_test_in_fortio 6 "c-with-r4j-cb" "10" "120s" "${SERVICE_URL}${PATH_THROW_ERROR_WITH_CB}"
# sleep 60
# Istio konfigurieren
# Istio testen


print_message "END TESTSUITE" ""