# KUBERNETES ( SINGLE NODE )
Crea la version mas simple posible de un cluster kubernetes en donde una solo instancia funge como 'maestro' y 'nodo' a la vez.

Crear la instancia:

```
vagrant up
```

Instalar e iniciar los servicios de kubernetes:

```
fleetctl --endpoint=http://VAGRANT_MACHINE_IP:4001 load services/*
fleetctl --endpoint=http://VAGRANT_MACHINE_IP:4001 start services/*
```

