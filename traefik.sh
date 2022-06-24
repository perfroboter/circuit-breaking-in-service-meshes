#see: https://doc.traefik.io/traefik-mesh/quickstart/
#Hinweis: Helm-Repo sollte nicht innerhalb des Repos sein, da sonst skaffold angepasst werden müsste
helm repo add traefik-mesh https://helm.traefik.io/mesh
helm repo update
helm install traefik-mesh traefik-mesh/traefik-mesh
# Per-Node-Proxy sollte dann laufen
# neue Service-Discovery von traefik nutzen
# Circuit-Breaking ist am einfachsten per Annotation einstellbar
# einfach in YAML des Services schreiben
# mesh.traefik.io/circuit-breaker-expression: "ResponseCodeRatio(500, 600, 0, 600) > 0.25"
# vgl. https://doc.traefik.io/traefik-mesh/configuration/#circuit-breaker bzw. https://doc.traefik.io/traefik/v2.0/middlewares/circuitbreaker/#configuration-options

