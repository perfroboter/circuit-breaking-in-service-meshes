
echo "### Funktionstest Circuit Breaker über Istio - OutlierDetection"
echo "### Voher: Istio-Config istio-config/fac-circuit-breaker-istio-outlier.yaml aktivieren"
echo "### Schritt 1: Normaler Aufruf - Erwartetes Ergebnis: 200 0K"
kubectl exec tester -- curl http://micronautfactorialservice:8080/fac/5 -v
echo "### Schritt 2: Drei facher Error-Aufruf, der einen Fehler produziert - Erwartetes Ergebnis: 500 Internal Server Error"
kubectl exec tester -- curl http://micronautfactorialservice:8080/error -v
kubectl exec tester -- curl http://micronautfactorialservice:8080/error -v
kubectl exec tester -- curl http://micronautfactorialservice:8080/error -v
echo "### Schritt 3: Erneuteres Aufruf nach 5s - Erwartetes Ergebnis: Circuit Breaker ist nun OPEN: 503"
sleep 5
kubectl exec tester -- curl http://micronautfactorialservice:8080/fac/5 -v
echo "### Schritt 4: Erneuteres Aufruf nach 35s - Erwartetes Ergebnis: Circuit Breaker ist nun wieder CLOSED: 200 OK"
sleep 35
kubectl exec tester -- curl http://micronautfactorialservice:8080/fac/5 -v