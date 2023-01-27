# Smart Contract para Trazabilidad de Hidrógeno Verde - Blockchain Innova

# Descripción

El hidrógeno verde es un combustible utilizado con el fin de obtener energía sustentable y mitigar el calentamiento global. Asoma como una alternativa a los combustibles que emiten dióxido de carbono.

El estado final del hidrógeno no depende de la metodología que se haya utilizado para obtenerlo. Por lo tanto, es necesario obtener soluciones que faciliten asentar las etapas afectan el estado del producto de una forma confiable, hasta llegar al consumidor final. De esta forma, se puede verificar el impacto ambiental del activo producido.

Se ha realizado una implementación de trazabilidad con blockchain debido a la inmutabilidad, descentralización y transparencia que provee la tecnología. Este enfoque ya ha sido implementado exitosamente en cadenas de suministro a gran escala [1].

Se ha diseñado un código en el lenguaje Solidity, que principalmente es utilizado para desplegar contratos inteligentes en la plataforma Ethereum.

Se ha tokenizado el activo porque puede proveer nuevos beneficios para atraer a consumidores de hidrógeno verde y facilitar la aceptación del mismo. En nuestro caso la tokenización del activo es un proceso coherente a su venta. 

# Describiendo un lote de Hidrógeno

Para detallar los atributos y respectivos cambios de un lote de hidrógeno se ha definido una estructura de datos denominada TRU (traceable resource unit). 

Cada vez que el productor elabora el activo, crea una instancia de esta estructura.

Atributos:

“id”: identificador del TRU.  Único.

“owner”: lista append-only que contiene los sucesivos propietarios del activo.

“holder”: lista append-only que guarda los sucesivos portadores del activo.

“hydrogenType”: color del activo, que debe ser de los tipos “green”, “yellow” o “pink”.

“assetState”: que define si se ha obtenido Hidrógeno (“H”) o Amoníaco (“NH3”).

“quantity”: que determina la cantidad de masa de Hidrógeno producido en el lote.


Cada TRU se almacena en una lista append-only ”allTRU” (es public, para más transparencia) que contiene a todos los TRU.

# Actores implicados en la cadena de producción

Se han establecido tres actores que participan en las etapas del proceso productivo: 
Productor → createTRU, soldTRU, sendTRUtransporter
Transportista: encargado de llevar el activo de un lugar a otro, sin ser propietario de este en ningún momento → sendTRUconsumer
Consumidor: es el último eslabón de la cadena, que recibe el producto de parte del transportista, luego de haber comprado el activo y puede utilizarlo → utilizeHydrogen

Funciones para consultas: getTRUowner, getTRUholder, getTRUquantity, allTRU

Cada uno de los actores interactúan a través de una cuenta, con una address asociada.

# Tokenización

El consumidor final tendrá la opción de comercializar fracciones de su lote de hidrógeno en un mercado establecido en la blockchain, aumentando la liquidez del comercio del mismo. 

En la implementación realizada, al desplegar el smart contract, los tokens son creados únicamente cuando se produce hidrógeno verde, a modo de incentivo para el consumo. La idea es que el token esté respaldado por Hidrógeno físico.

La cantidad de tokens creada es on-demand (se utiliza la función "mint")y es proporcional a la cantidad de Hidrógeno → 100 tokens por unidad de Hidrógeno.

En caso de utilizar el Hidrógeno, el consumidor deberá asentar esta acción en la blockchain. Esto permitirá que los tokens asociados sean eliminados, ya que el respaldo de ellos ya no existirá (se utiliza la función "burn"). 

Se ha utilizado el standard de tokens fungibles ERC20.

# Referencias

[1] https://www.hyperledger.org/learn/publications/walmart-case-study
