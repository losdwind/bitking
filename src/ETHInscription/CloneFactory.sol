// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../../src/eth-inscription/Inscription.sol";
import "forge-std/console.sol";

// interface Implementation {
//     function deployInscription(
//         address _owner,
//         string calldata _symbol,
//         uint _totalSupply,
//         uint _perMint,
//         uint _price
//     ) external;

//     function mint(address account) external payable;
// }

contract CloneFactory {
    address immutable baseContract;
    uint public immutable fee;
    mapping(address => address[]) public allClones;

    event InscriptionCreated(address inscriptionCA);

    constructor(address _baseContract, uint _fee) {
        baseContract = _baseContract;
        fee = _fee;
    }

    receive() external payable {}

    function deployInscription(
        string calldata _symbol,
        uint _totalSupplyLimit,
        uint _perMint,
        uint _price,
        uint _fee
    ) external {
        address clone = Clones.clone(baseContract);
        console.log("cloned contract address: %s", clone);
        Inscription(payable(clone)).initialize(
            msg.sender,
            _symbol,
            _totalSupplyLimit,
            _perMint,
            _price,
            _fee
        );
        allClones[msg.sender].push(clone);
        emit InscriptionCreated(clone);
    }

    function mintInscription(address tokenAddr) external payable {
        console.log("start to mint", msg.sender, msg.sender.balance);
        require(
            msg.value >=
                Inscription(payable(tokenAddr)).price() +
                    fee +
                    Inscription(payable(tokenAddr)).fee(),
            "insufficient payment"
        );
        Inscription(payable(tokenAddr)).mint{
            value: Inscription(payable(tokenAddr)).price() +
                Inscription(payable(tokenAddr)).fee()
        }(msg.sender);
    }

    function returnClones(
        address _owner
    ) external view returns (address[] memory) {
        return allClones[_owner];
    }
}
