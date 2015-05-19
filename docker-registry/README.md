# DOCKER REGISTRY
Crea una imagen base para correr un registro privado de imagenes Docker.

Crear un build:

```
./build.sh v2.0.1 my_registry
```

Ejecutar el registro:

```
docker run -p 443:5000 --env-file ./SETUP image_name
```