#!/bin/sh

deploy_fortio() {
  kubectl apply -f ../istio-config/deploy-load-tester.yaml
}

t1() {
  echo "Test 1: Testen von Istio ohne Circuit-Breaker unter Variierung der Connection-Anzahl"
  run-connections
}


run-connections() {
echo "Run 1a: 5 Connections, 500 Aufrufe"
  kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 5 -n 500 -loglevel Fatal http://micronautncrservice:8080/ncr/10000/5000
  echo "Run 1b: 10 Connections, 500 Aufrufe"
  kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 10 -n 500 -loglevel Fatal http://micronautncrservice:8080/ncr/10000/5000
  echo "Run 1c: 20 Connections, 500 Aufrufe"
  kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 20 -n 500 -loglevel Fatal http://micronautncrservice:8080/ncr/10000/5000
  echo "Run 1d: 40 Connections, 500 Aufrufe"
  kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 40 -n 500 -loglevel Warning http://micronautncrservice:8080/ncr/10000/5000
    echo "Run 1c: 80 Connections, 500 Aufrufe"
  kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 80 -n 500 -loglevel Warning http://micronautncrservice:8080/ncr/10000/5000
}

case "$1" in
  deploy_fortio)
    deploy_fortio
    exit 0
    ;;
  t1)
    t1
    exit 0
    ;;
  t2)
    t2
    exit 0
    ;;
  t3)
    t3
    exit 0
    ;;
  *)
    echo "Could not match to valid command"
    exit 1
    ;;
esac