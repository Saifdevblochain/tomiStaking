
// SPDX-License-Identifier: GPL

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract miniPioneerNFT is ERC721{

    uint private ID;

    constructor () ERC721("miniPioneer", "miniPioneer") {

    }

    function mint( address to  ) public {
        _mint(to, ID);
        ID++;
    }

}
