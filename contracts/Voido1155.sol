// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *
 * This contract uses {Ownable}
 */
contract Voido is Context, Ownable, ERC1155Burnable {
    address proxyRegistryAddress;
    bool isProxyEnabled = false;

    struct RankProperty {
        uint256 price;
        uint256 maxAmount;
    }
    struct ItemProperty {
        uint256 price;
        uint256 count;
        uint256 rank;
        uint256 atk;
        uint256 def;
    }

    event LogDeposit(address sender, uint256 amount);
    event LogTransfer(address sender, address to, uint256 amount);

    mapping(uint256 => RankProperty) private RankProperties;
    mapping(uint256 => ItemProperty) private ItemProperties;
    struct Order {
        uint256 price;
        uint256 amount;
    }

    // From ERC721 registry assetId to Order (to avoid asset collision)
    // mapping(address => mapping(uint256 => Order)) public userOrders;

    bool private presale = true;

    mapping(address => uint256) etherBalances;

    function setConfig(
        address _proxyRegistryAddress,
        bool _isProxyEnabled,
        bool _presale
    ) public virtual onlyOwner {
        proxyRegistryAddress = _proxyRegistryAddress;
        isProxyEnabled = _isProxyEnabled;
        presale = _presale;
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     *
     * Ranks
     *   1-> Common
     *   2-> Rare
     *   3-> Epic? Legendary
     *   4-> Divine
     *
     */

    constructor(string memory uri) ERC1155(uri) {
        RankProperties[1] = RankProperty(1 * 10**17, 20);
        RankProperties[2] = RankProperty(3 * 10**17, 10);
        RankProperties[3] = RankProperty(1 * 10**18, 5);
        RankProperties[4] = RankProperty(100 * 10**18, 1);
    }

    function name() external pure returns (string memory) {
        return "Boido Store";
    }

    function symbol() external pure returns (string memory) {
        return "Void";
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override(ERC1155)
        returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.

        if (isProxyEnabled) {
            ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
            if (address(proxyRegistry.proxies(_owner)) == _operator) {
                return true;
            }
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        uint256 rank,
        uint256 atk,
        uint256 def,
        bytes memory data
    ) public virtual onlyOwner {
        _mint(to, id, amount, data);
        changeIdData(id, amount, rank, atk, def);
    }

    function changeIdData(
        uint256 id,
        uint256 amount,
        uint256 rank,
        uint256 atk,
        uint256 def
    ) internal {
        ItemProperty memory itemProperty = ItemProperties[id];

        if (itemProperty.count > 0) {
            ItemProperties[id] = ItemProperty(
                itemProperty.price,
                itemProperty.count + amount,
                itemProperty.rank,
                itemProperty.atk,
                itemProperty.def
            );
        } else {
            RankProperty memory rankProperty = RankProperties[rank];

            ItemProperties[id] = ItemProperty(
                rankProperty.price,
                amount,
                rank,
                atk,
                def
            );
        }
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        uint256[] memory ranks,
        uint256[] memory atk,
        uint256[] memory def,
        bytes memory data
    ) public virtual onlyOwner {
        _mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; ++i) {
            changeIdData(ids[i], amounts[i], ranks[i], atk[i], def[i]);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function buyItemFromPreSale(
        uint256 id,
        uint256 amount,
        address to,
        address payable from
    ) public payable {
        ItemProperty memory itemProperty = ItemProperties[id];
        RankProperty memory rankProperty = RankProperties[itemProperty.rank];
        require(from == owner(), "from must be owner");
        require(presale == true, "presale is disabled");
        require(amount > 0, "amount must be > 0");
        require(msg.value > 0, "value must be > 0");
        require(itemProperty.price > 0, "price must be > 0");
        require(itemProperty.count > 0, "itemcount must be > 0");
        require(
            itemProperty.count + amount <= rankProperty.maxAmount,
            "itemcount exceeds allowed amount"
        );
        require(
            msg.value == itemProperty.price * amount,
            "price is not correct"
        );
        _mint(to, id, amount, "");
        from.transfer(msg.value);

        changeIdData(
            id,
            amount,
            itemProperty.rank,
            itemProperty.atk,
            itemProperty.def
        );
    }

    function setRankData(
        uint256 rank,
        uint256 price,
        uint256 maxAmount
    ) public onlyOwner {
        RankProperties[rank] = RankProperty(price, maxAmount);
    }

    function setItemData(
        uint256 id,
        uint256 rank,
        uint256 count,
        uint256 atk,
        uint256 def,
        uint256 price
    ) public onlyOwner {
        ItemProperties[id] = ItemProperty(price, count, rank, atk, def);
    }

    function getRankData(uint256 rank)
        public
        view
        returns (RankProperty memory)
    {
        return RankProperties[rank];
    }

    function getItemDatas(uint256[] memory ids)
        public
        view
        returns (ItemProperty[] memory)
    {
        ItemProperty[] memory batchBalances = new ItemProperty[](ids.length);

        for (uint256 i = 0; i < ids.length; ++i) {
            batchBalances[i] = ItemProperties[ids[i]];
        }

        return batchBalances;
    }
}
