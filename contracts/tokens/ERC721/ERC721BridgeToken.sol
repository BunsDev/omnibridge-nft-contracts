pragma solidity 0.7.5;

import "./ERC721.sol";
import "../../interfaces/IOwnable.sol";
import "../../interfaces/IBurnableMintableERC721Token.sol";

/**
 * @title ERC721BridgeToken
 * @dev template token contract for bridged ERC721 tokens.
 */
contract ERC721BridgeToken is ERC721, IBurnableMintableERC721Token {
    address public bridgeContract;

    /**
     * @dev Throws if sender is not a bridge contract.
     */
    modifier onlyBridge() {
        require(msg.sender == bridgeContract);
        _;
    }

    /**
     * @dev Throws if sender is not a bridge contract or bridge contract owner.
     */
    modifier onlyOwner() {
        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        _;
    }

    /**
     * @dev Tells if this contract implements the interface defined by
     * `interfaceId`. See the corresponding EIP165.
     * @return true, if interface is implemented.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        bytes4 INTERFACE_ID_ERC165 = 0x01ffc9a7;
        bytes4 INTERFACE_ID_ERC721 = 0x80ac58cd;
        bytes4 INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
        bytes4 INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
        return
            interfaceId == INTERFACE_ID_ERC165 ||
            interfaceId == INTERFACE_ID_ERC721 ||
            interfaceId == INTERFACE_ID_ERC721_METADATA ||
            interfaceId == INTERFACE_ID_ERC721_ENUMERABLE;
    }

    /**
     * @dev Mint new ERC721 token.
     * Only bridge contract is authorized to mint tokens.
     * @param _to address of the newly created token owner.
     * @param _tokenId unique identifier of the minted token.
     */
    function mint(address _to, uint256 _tokenId) external override onlyBridge {
        _safeMint(_to, _tokenId);
    }

    /**
     * @dev Burns some ERC721 token.
     * Only bridge contract is authorized to burn tokens.
     * @param _tokenId unique identifier of the burned token.
     */
    function burn(uint256 _tokenId) external override onlyBridge {
        _burn(_tokenId);
    }

    /**
     * @dev Updated bridged token name/symbol parameters.
     * Only bridge owner or bridge itself can call this method.
     * @param name new name parameter, will be saved as is, without additional suffixes like " from Mainnet".
     * @param symbol new symbol parameter.
     */
    function setMetadata(string calldata name, string calldata symbol) external onlyOwner {
        require(bytes(name).length > 0 && bytes(symbol).length > 0);

        _name = name;
        _symbol = symbol;
    }

    /**
     * @dev Sets the base URI for all tokens.
     * Can be called by bridge owner after token contract was instantiated.
     * @param _baseURI new base URI.
     */
    function setBaseURI(string calldata _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    /**
     * @dev Updates the bridge contract address.
     * Can be called by bridge owner after token contract was instantiated.
     * @param _bridgeContract address of the new bridge contract.
     */
    function setBridgeContract(address _bridgeContract) external onlyOwner {
        require(_bridgeContract != address(0));
        bridgeContract = _bridgeContract;
    }

    /**
     * @dev Sets the URI for the particular token.
     * Can be called by bridge owner after token bridging.
     * @param _tokenId URI for the bridged token metadata.
     * @param _tokenURI new token URI.
     */
    function setTokenURI(uint256 _tokenId, string calldata _tokenURI) external override onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }

    /**
     * @dev Tells the current version of the ERC721 token interfaces.
     */
    function getTokenInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {
        return (1, 1, 0);
    }
}