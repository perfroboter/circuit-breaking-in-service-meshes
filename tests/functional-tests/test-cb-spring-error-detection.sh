
  echo -e "### Funktionstest Circuit Breaker über Spring Cloud / R4J - Default config"
  echo -e "### Schritt 1: Normaler Aufruf - Erwartetes Ergebnis: 200 0K"
  kubectl exec tester -- curl  -w " %{http_code}\n" http://springfactorialservice:8080/fac/5
  echo "### Schritt 2: 100 Aufrufe mit min. 50% (hier 100%) Fehlerquote - Erwartetes Ergebnis: Circuit Breaker schaltet"
  kubectl exec tester -- curl  -w " %{http_code} - 100 Times (no output)\n" http://springfactorialservice:8080/error/
  for i in `seq 1 99`; do kubectl exec tester -- curl http://springfactorialservice:8080/error/ -s -o /dev/null; done
  echo -e "### Schritt 3: Erneuteres Aufruf nach 5s - Erwartetes Ergebnis: Circuit Breaker ist nun OPEN: kein 200 OK"
  sleep 5
  kubectl exec tester -- curl  -w " %{http_code}\n" http://springfactorialservice:8080/fac/5
   echo -e "### Schritt 4: Erneuteres Aufruf nach 65s - Erwartetes Ergebnis: Circuit Breaker ist nun wieder CLOSED: 200 OK"
  sleep 65
  kubectl exec tester -- curl  -w " %{http_code}\n" http://springfactorialservice:8080/fac/5