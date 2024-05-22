// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// Se utiliza tokens ERC20 de Open Zeppelin.
/// Se trabaja con la opción de que los tokens sean 'Burnable'.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @author Franco Cerino - Carlos Alberto Peña Montenegro
 * @title Smart contract for traceability and tokenization of Hydrogen.
 * @dev
 * El contrato inteligente hace énfasis en dos aplicaciones:
 * - Trazabilidad.
 * Se asienta características y movimientos de los lotes de hidrógeno
 * en la blockchain para contribuir a la transparencia de la cadena
 * de suministro del activo. Blockchain permite esto ya que es una
 * tecnología que provee una base de datos inmutable, descentralizada
 * y transparente.
 *
 * - Tokeninación.
 * Utiliza las implementaciones de OpenZeppelin 'ERC20' y 'ERC20Burnable'.
 * 'ERC20' para crear tokens fungibles, los cuales estarán respaldados por un
 * activo físico, Hidrógeno en este caso.
 * Se ha utilizado 'ERC20Burnable' con la idea de que si el Hidrógeno
 * es consumido o deja de ser tenido en cuenta, en caso de haber emitido tokens
 * asociados, estos se puedan eliminar para poder mantener una correspondencia
 * entre cantidad de tokens y cantidad total de Hidrógeno.
 */
contract GreenHydrogenContract is ERC20, ERC20Burnable {
  /// cambiar por las address a utilizar antes de desplegar el contrato
  address producer_address = 0x0531262Ef42AF2d1aC21f2058022C9e65f35867F;
  address transporter_address = 0xb4b2d0Cb2426175a25922E7D3954cac314F99fB5;
  address consumer_address = 0x6F6c6D9868d452EC580fC1422f47776a5C73676F;

  /*
   * @dev
   * Constructor de un token específico para la aplicación,
   * el cual estará respaldado por Hidrógeno físico, con nombre
   * 'GreenHydrogenToken' y ticker 'GHT'.
   */
  constructor() ERC20("GreenHydrogenToken", "GHT") {}

  /*
   * @dev
   * Función importada de 'ERC20'.
   * Permite crear una cantidad 'amount' de tokens fugibles,
   * los cuales serán asignados a la dirección (o address) 'to'.
   */
  function mint(address to, uint256 amount) internal {
    _mint(to, amount);
  }

  /*
   * @dev
   *'TRU' (Traceable Resource Unit) es una estructura de datos que detalla los atributos
   * y cambios de un lote de Hidrógeno.
   * Cada vez que el productor elabora un lote del activo, crea una instancia de esta
   * estructura.
   * las listas 'owner' y 'holder' son append-only (solo se puede añadir elementos nuevos),
   * para dar persistencia a los datos.
   */
  struct TRU {
    uint id; /// id = índice (u orden) del TRU en la lista 'allTRU'.
    string[] owner; /// propietario del activo.
    string[] holder; /// persona física que porta el asset. Un ejemplo es el transportista.
    string hydrogenType; /// 'green', 'yellow', 'pink'.
    string assetState; /// Hidrógeno ('H2') o amoníaco ('NH3').
    uint quantity; /// masa total efectiva de Hidrógeno en el lote.
  }

  /*
   * @dev
   * Cada 'TRU' se almacena en una lista append-only 'allTRU' (es una variable public,
   * para mayor transparencia) que contiene a todos los TRU creados.
   */
  TRU[] public allTRU;

  /*
   * @dev
   * Modificador para utilizar con una función. Al utilizarlo, para que se ejecute la
   * función, la address asociada a la llamada de esta debe ser '_address'.
   */
  modifier requirement_msg_sender(address _address) {
    require(msg.sender == _address);
    _;
  }

  /*
   * @dev
   * Modificador que especifica que para que la función asociada sea ejecutada
   * solo si se cumple que el atributo '_attribute' dado cumpla con el valor
   * '_type'.
   * '_attribute' puede ser 'owner' o 'holder'.
   * Por ejemplo, puede ser usado si se quiere constatar que al momento de
   * realizar una operación, el owner es el productor.
   */
  modifier requirement_TRU(
    uint _id,
    string memory _attribute,
    string memory _type
  ) {
    if (
      keccak256(abi.encodePacked(_attribute)) ==
      keccak256(abi.encodePacked("owner"))
    ) {
      require(
        keccak256(
          abi.encodePacked(allTRU[_id].owner[allTRU[_id].owner.length - 1])
        ) == keccak256(abi.encodePacked(_type))
      );
    } else if (
      keccak256(abi.encodePacked(_attribute)) ==
      keccak256(abi.encodePacked("holder"))
    ) {
      require(
        keccak256(
          abi.encodePacked(allTRU[_id].holder[allTRU[_id].holder.length - 1])
        ) == keccak256(abi.encodePacked(_type))
      );
    }
    _;
  }

  /*
   * @dev
   * Función para crear un nuevo TRU y añadirlo a la lista 'allTRU'.
   * El tipo de Hidrógeno debe ser verde ('green'), amarillo ('yellow')
   * o rosa ('pink').
   * Debe estar en estado puro ('H2') o como Amoniaco ('NH3').
   * La función solo puede ser ejecutada por el productor ('producer_address').
   */
  function createTRU(
    string memory _hydrogenType,
    string memory _assetState,
    uint _quantity
  ) external requirement_msg_sender(producer_address) {
    require(
      keccak256(abi.encodePacked(_hydrogenType)) ==
        keccak256(abi.encodePacked("green")) ||
        keccak256(abi.encodePacked(_hydrogenType)) ==
        keccak256(abi.encodePacked("yellow")) ||
        keccak256(abi.encodePacked(_hydrogenType)) ==
        keccak256(abi.encodePacked("pink"))
    );

    require(
      keccak256(abi.encodePacked(_assetState)) ==
        keccak256(abi.encodePacked("H2")) ||
        keccak256(abi.encodePacked(_assetState)) ==
        keccak256(abi.encodePacked("NH3"))
    );

    string[] memory _producer = new string[](1);
    _producer[0] = "producer";

    allTRU.push(
      TRU(
        allTRU.length,
        _producer,
        _producer,
        _hydrogenType,
        _assetState,
        _quantity
      )
    );
  }

  /*
   * @dev
   * Función que devuelve quien es el propietario del lote de Hidrógeno.
   */
  function getTRUowner(uint _id) external view returns (string[] memory) {
    return allTRU[_id].owner;
  }

  /*
   * @dev
   * Función que devuelve quien posee físicamente al lote de Hidrógeno.
   * No necesariamente es el propietario, ya que puede tenerlo la
   * entidad que funciona como transporte.
   */
  function getTRUholder(uint _id) external view returns (string[] memory) {
    return allTRU[_id].holder;
  }

  /*
   * @dev
   * Función que devuelve la cantidad de 'TRU' creados.
   */
  function getTRUquantity() external view returns (uint) {
    return allTRU.length;
  }

  /*
   * @dev
   * Función que explicita que se ha realizado la venta de un lote de
   * Hidrógeno a un consumidor final.
   * Solo puede ser ejecutada por el productor de lotes de Hidrógeno.
   * Para que sea ejecutada, también se debe cumplir que el propietario
   * del lote sea el productor.
   */
  function soldTRU(
    uint _id
  )
    external
    requirement_msg_sender(producer_address)
    requirement_TRU(_id, "owner", "producer")
  {
    allTRU[_id].owner.push("consumer");
  }

  /*
   * @dev
   * Función que asenta que el lote de Hidrógeno que tiene el índice '_id'
   * en la lista 'allTRU', se entrega al transportista.
   * Para que la función se ejecute, se debe haber realizado la venta del
   * lote de Hidrógeno '_id' a un consumidor y debe estar en manos del
   * productor.
   */
  function sendTRUtransporter(
    uint _id
  )
    external
    requirement_msg_sender(producer_address)
    requirement_TRU(_id, "owner", "consumer")
    requirement_TRU(_id, "holder ", "producer")
  {
    allTRU[_id].holder.push("transporter");
  }

  /*
   * @dev
   * Función que asenta que el lote '_id' está en manos del consumidor
   * final.
   * Esta función debe ser ejecutada por el transportista, el cual le
   * entrega el lote al consumidor final.
   * En caso de ser Hidrógeno totalmente sustentable (verde), se crea
   * una cantidad de tokens proporcional a la masa total de Hidrógeno
   * en el lote y se las entrega al consumidor.
   */
  function sendTRUconsumer(
    uint _id
  )
    external
    requirement_msg_sender(transporter_address)
    requirement_TRU(_id, "owner", "consumer")
    requirement_TRU(_id, "holder ", "transporter")
  {
    allTRU[_id].holder.push("consumer");

    if (
      keccak256(abi.encodePacked(allTRU[_id].hydrogenType)) ==
      keccak256(abi.encodePacked("green"))
    ) {
      mint(consumer_address, 100 * 10 ** 18 * allTRU[_id].quantity);
    }
  }

  /*
   * @dev
   * Función que asenta que el lote de Hidrógeno '_id' ha sido consumido.
   * Solo puede ser utilizada por el consumidor.
   * Todos los tokens asociados al lote de Hidrógeno '_id' se eliminan
   * con la función importada 'burn'.
   */
  function utilizeHydrogen(
    uint _id
  ) external requirement_msg_sender(consumer_address) {
    allTRU[_id].assetState = "utilized";
    burn(100 * 10 ** 18 * allTRU[_id].quantity);
  }
}
