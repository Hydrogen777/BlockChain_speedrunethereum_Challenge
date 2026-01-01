pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

// 1. Đã mở comment dòng này để dùng được hàm onlyOwner
import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

// 2. Thêm "is Ownable" để kế thừa
contract Vendor is Ownable {

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    // 3. Cập nhật constructor để thiết lập chủ sở hữu (msg.sender)
    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Gui ETH de mua token");
        uint256 amountToBuy = msg.value * tokensPerEth;
        
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        require(vendorBalance >= amountToBuy, "Vendor khong du token");

        (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
        require(sent, "Giao dich that bai");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);
    }

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Khong co ETH de rut");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Rut tien that bai");
    }

    function sellTokens(uint256 _amount) public {
        require(_amount > 0, "Phai ban nhieu hon 0 token");

        uint256 amountOfETHToTransfer = _amount / tokensPerEth;
        uint256 ownerETHBalance = address(this).balance;
        require(ownerETHBalance >= amountOfETHToTransfer, "Vendor khong du ETH de tra");

        (bool sent) = yourToken.transferFrom(msg.sender, address(this), _amount);
        require(sent, "Chuyen token that bai");

        (bool success,) = msg.sender.call{value: amountOfETHToTransfer}("");
        require(success, "Tra ETH that bai");

        emit SellTokens(msg.sender, _amount, amountOfETHToTransfer);
    }
}
