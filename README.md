## Manejo de Clusters

Experimentos y ejemplos de distintos setups para la creación y administración de plataformas basadas en clusters para el despliegue de servicios definidos en contenedores.

Dependencias:

- virtualbox
- vagrant
- fleetctl
- kubectl

En Mac:

```
brew-cask install virtualbox
brew install vagrant fleetctl kubernetes-cli
```

Cada ejemplo puede iniciarse utilizando en script __up.sh__ incluido:

```
./up.sh
```