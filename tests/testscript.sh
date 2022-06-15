#!/bin/bash

FORTIO_POD=$(kubectl get pods | grep -o "fortio-deploy[A-Za-z0-9-]*")
FORTIO_DOWNLOAD_URL="http://$( kubectl get service fortio --template '{{.status.loadBalancer.ingress}}' | grep -o "[0-9.]*"):8080/fortio/data/"

SERVICE_URL_KUBERNETES="http://springfactorialservice:8080"
SERVICE_URL_TRAEFIK="http://springfactorialservice.default.traefik.mesh:8080"
PATH_WITH_R4J_CB="/fac-with-cb/"
PATH_WITHOUT_CB="/fac-without-cb/"
PATH_FAC_WITH_CONFIG="/fac-with-config/"
PATH_DELAY_WITH_CONFIG="/delay-with-config/"
PATH_THROW_ERROR_WITH_CB="/throw-error-with-cb"
PATH_THROW_EROR_WITHOUT_CB="/throw-error-without-cb"
QPS=10
DURATION=120
OVERLOAD_DELAY=200
WORKLOADS=('5' '5000' '10000' '15000' '20000' '30000')
TESTRESULT_FOLDER="tests/testresults/"
SLEEPTIME=35


print_heading() {
    NOCOLOR='\033[0m' # No Color
    BLUE='\033[0;34m'
    HT="#####################"
    printf "${BLUE} $HT $1 \t$HT ${NOCOLOR}\n"
}

get_request_params() {
    #Parameter 1. isCB "true" / "false" 2. Seconds until errors 3. Duration of errors in secounds 4. DELAY
    TIME_IN_MILLIS=$(($(date +%s%N)/1000000))
    TIME_FROM=$((TIME_IN_MILLIS+$2*1000))
    TIME_UNTIL=$((TIME_FROM+$3*1000))
    TIME_DELAY=""
    if [ "$#" -eq 4 ]; then
        TIME_DELAY="&delay=$4"
    fi
    echo "?isCB=$1&from=${TIME_FROM}&until=${TIME_UNTIL}${TIME_DELAY}"
}

run_test_in_fortio() {
   timestamp=$(date +%Y-%m-%d-%H-%M-%S)
   print_heading "START TESTRUN $1"
   echo "Name: $1 Time: $timestamp"
   filename="$timestamp-$1.json"
   kubectl exec $FORTIO_POD -c fortio -- /usr/bin/fortio load -json $filename -qps $2 -t $3 -allow-initial-errors -labels "${1}" $4 # >& /dev/null
   curl "${FORTIO_DOWNLOAD_URL}${filename}" -o "${TESTRESULT_FOLDER}${filename}" #>& /dev/null
   echo "Json-Result saved to $filename" 
   print_heading "END TESTRUN $1"
}

#Parameter
# 1. Name/Label (bsp. without-cb-in-istio)
# 2. Use Traefik-Service-Discovery? [true/false]
# 3. Use Istio-CB? [true/false]

if [ "$#" -ne 3 ]; then
    echo "[Error] Wrong number of arguments."
    exit 8
fi

testprocedure_name=$1
testprocedure_service_url=$SERVICE_URL_KUBERNETES
testprocedure_path_fac=$PATH_WITHOUT_CB
testprocedure_path_error=$PATH_THROW_EROR_WITHOUT_CB
testprocedure_path_trans_error=$PATH_FAC_WITH_CONFIG
testprocedure_path_trans_overload=$PATH_DELAY_WITH_CONFIG
testprocedure_qps_normal=$QPS
testprocedure_qps_overload=$QPS
testprocedure_workload_normal="${WORKLOADS[1]}"
testprocedure_workload_overload="${WORKLOADS[5]}"
testprocedure_overload_delay=$OVERLOAD_DELAY
testprocedure_trans_time=$(($DURATION/3))
testprocedure_is_r4j_cb="false"
testprocedure_t="${DURATION}s"

if [ "$2" = true ]
    then
        testprocedure_service_url=$SERVICE_URL_TRAEFIK
fi

if [ "$3" = true ]
    then
        testprocedure_is_r4j_cb="true"
        testprocedure_path_fac=$PATH_WITH_R4J_CB
        testprocedure_path_error=$PATH_THROW_EROR_WITH_CB
fi

# Positivtestfall - Normales Verhalten
run_test_in_fortio "normal-${testprocedure_name}" $testprocedure_qps_normal $testprocedure_t "${testprocedure_service_url}${testprocedure_path_fac}${testprocedure_workload_normal}"
sleep $SLEEPTIME
# Permanetene Fehler
run_test_in_fortio "perm-error-${testprocedure_name}" $testprocedure_qps_normal $testprocedure_t "${testprocedure_service_url}${testprocedure_path_error}"
sleep $SLEEPTIME
# Permanente Überlast
run_test_in_fortio "perm-overload-${testprocedure_name}" $testprocedure_qps_overload $testprocedure_t "${testprocedure_service_url}${testprocedure_path_fac}${testprocedure_workload_overload}"
sleep $SLEEPTIME
# Transiente Fehler
run_test_in_fortio "trans-error-${testprocedure_name}" $testprocedure_qps_normal $testprocedure_t "${testprocedure_service_url}${testprocedure_path_trans_error}${testprocedure_workload_normal}$(get_request_params $testprocedure_is_r4j_cb $testprocedure_trans_time $testprocedure_trans_time)"
sleep $SLEEPTIME
# Transiente Überlast 
#TODO: Überlast wird nur durch Workload bzw. DELAY und nicht durch QPS
run_test_in_fortio "trans-overload-${testprocedure_name}" $testprocedure_qps_normal $testprocedure_t "${testprocedure_service_url}${testprocedure_path_trans_overload}${testprocedure_workload_normal}$(get_request_params $testprocedure_is_r4j_cb $testprocedure_trans_time $testprocedure_trans_time $testprocedure_overload_delay)"
sleep $SLEEPTIME
# Chaos
# TODO: Fehler und Überlast gleichzeitig