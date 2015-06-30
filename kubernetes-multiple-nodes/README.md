# KUBERNETES ( MULTIPLE NODES )
Crea un cluster local kubernetes con un 'maestro' y multiples 'nodos'.

Una vez que todas las unidad se encuentren activas:

```
fleetctl list-units
```

Podemos comenzar a inspeccionar y utilizar el cluster:

```
kubectl -s ${KUBERNETES_MASTER}:8080 cluster-info
kubectl -s ${KUBERNETES_MASTER}:8080 get nodes
```