# Anleitung zur Installation und Testdurchführung
Folgende Anleitung ermöglicht das Aufsetzten des Prototyps in Minikube auf einem Linux-System (TODO: Teils auch für MacOS).

## Teil 1: Kubernetes (Minikube) etc. installieren
Vorraussetzungen:
    - Docker ist installiert

```bash
# Kubectl installieren
 ./manage-cluster.sh install-kubectl
# Minikube installieren (Aufgrund eines IT-Sicherheitsproblems der Fachhochschule kann hier nicht auf eine Mult-Node-Cluster zuzrückgegriffen werden.)
./manage-cluster.sh install-minikube
# Skaffold installieren
./manage-cluster.sh install-skaffold && ./manage-cluster.sh setup-skaffold-for-local
# Services außerhalb des Clusters verfügbar machen (für Zugriff auf Fortio-Testdaten etc.)
minikube tunnel # im seperaten Terminalfenster offen lassen
```

## Teil 2: Istio installieren

```bash
# Istio bzw. istioctl installieren
 ./manage-cluster.sh install-istio
# Istio starten und Istio-Service-Injection auf Namespace "default" aktivieren
./mange-cluster.sh start-istio
```

## Teil 3: Beispielservice bereitstellen
```bash
# Pods/Services mittels Skaffold starten
skaffold run
```

## Teil 4: Erste Testserie im Istio-Service-Mesh durchführen
Hinweis: Im Testskript musste für die Durchführung auf MacOS gdate durch date ersetzt werden
```bash
# Testlauf im Service-Mesh-Istio starten
./tests/testsuite.sh testsuite-in-istio
```

## Teil 5: Istio deinstallieren und Traefik breitstellen
Vorraussetzung:
    - Helm ist installiert
```bash
# Pods/Services deaktivieren
skaffold delete
# Istio deinstallieren
./mange-cluster.sh uninstall-istio
# Traefik-Mesh installieren
./manage-cluster.sh install-traefik
# Pods/Services mittels Skaffold starten
skaffold run
```

## Teil 6: Zweite Testserie im Traefik-Mesh durchführen
```bash
# Testlauf im Service-Mesh Traefik starten
./tests/testsuite.sh testsuite-in-traefik
```

## Teil 7: Evaluation der Testergebnisse
Vorraussetzung:
    - jupyter notebook ist installiert

Evaluationsskript liest alle Testergebnisse im Ordner (Testskript ein) und legt dann nach Testfällen sortiert die Rohdaten und zugehörige Diagramme unter `tests/evaluation/evaluationresults/` ab (die aktuellen Diagramme liegen dort bereits).
```bash
# Jupyter starten
jupyter notebook
# Innerhalb von Jupyter zum Installationsskript wechseln
cd tests/evaluation/evaluation.ipynb
#Ggbfs. Filterung, dass nur gewisse Datensätze für die Diagramme berücksichtigt werden enfernen (errors_relevant und overload_relevant)
# "Run All" durchführen
```
