# AuiDrome

## TODOes

* Event Machine and accesses to disk: study (me) and fix.

* "To think" button should also behave like a "search in our dromes" button.

* Madrinos in the Auidrome should be able to choose a Glottolog language/dialect if desired.

## Ideas (Kind of "definition" in Spanish)

Un pequeño cajón desastre en castellano de donde deberían ir saliendo cosas hacia Trello, el código y el README.md

* una persona identificada que forme parte del pedalódromo podrá ver la información protegida (data/protected) de cualquier persona

* los usuarios pueden editar todas sus propiedades

* los usuarios pueden editar las propiedades públicas de aquellas personas a las que amadrinan

* cuando un usuario grita un nombre eso le convierte en madrino o madrina de esa persona. si no existe en ningún dromo la crea (si por el contrario existe simplenente gana un/a madrino/a).

### tuits.json, images, tuits, humans...

La información de una persona la tenemos repartida en los siguientes ficheros:

* en tuits.json tenemos, además del Auido (nombre) con el que una persona fue incorporada a un dromo, el momento en el que ocurrió.

* en public/images su foto pública en dicho dromo.

* en public/tuits/AUIDO.json su información pública.

* en data/protected/DROMO/tuits/AUIDO.json y data/private/DROMO/tuits/AUIDO.json su información protegida y privada.

No tengo claro el uso/sentido que puede tener data/ACCESS_LEVEL/DROMO/tuits.json más allá del public access level.

El acceso de escritura a esta información iría así:

* Yo puedo cambiar toda mi información incluída la privada.

* Mis madrinos pueden ver toda mi información, pero sólo pueden cambiar mi información pública.

* Mis compañer@s en el Pedalódromo pueden ver mi información protegida. No pueden cambiarla pero pueden añadirme nueva información (que será a su vez protegida).

