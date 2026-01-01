// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Corn.sol";
// import "./CornDEX.sol"; <--- TUYỆT ĐỐI KHÔNG IMPORT FILE NÀY

// Định nghĩa Interface riêng để không phụ thuộc vào file gốc của hệ thống chấm
interface ILendingDEX {
    function getEthPrice() external view returns (uint256);
}

error Lending__InvalidAmount();
error Lending__TransferFailed();
error Lending__UnsafePositionRatio();
error Lending__BorrowingFailed();
error Lending__RepayingFailed();
error Lending__PositionSafe();
error Lending__NotLiquidatable();
error Lending__InsufficientLiquidatorCorn();

contract Lending is Ownable {
    uint256 private constant COLLATERAL_RATIO = 120; 
    uint256 private constant LIQUIDATOR_REWARD = 10; 

    Corn private i_corn;
    
    ILendingDEX private i_cornDEX; 
    mapping(address => uint256) public s_userCollateral; 
    mapping(address => uint256) public s_userBorrowed; 

    event CollateralAdded(address indexed user, uint256 indexed amount, uint256 price);
    event CollateralWithdrawn(address indexed user, uint256 indexed amount, uint256 price);
    event AssetBorrowed(address indexed user, uint256 indexed amount, uint256 price);
    event AssetRepaid(address indexed user, uint256 indexed amount, uint256 price);
    event Liquidation(
        address indexed user,
        address indexed liquidator,
        uint256 amountForLiquidator,
        uint256 liquidatedUserDebt,
        uint256 price
    );

    constructor(address _cornDEX, address _corn) Ownable(msg.sender) {
        // Ép kiểu địa chỉ đầu vào thành Interface ILendingDEX
        i_cornDEX = ILendingDEX(_cornDEX); 
        i_corn = Corn(_corn);
        i_corn.approve(address(this), type(uint256).max);
    }

    function addCollateral() public payable {
        if (msg.value == 0) {
            revert Lending__InvalidAmount();
        }
        s_userCollateral[msg.sender] += msg.value;
        
        uint256 price = i_cornDEX.getEthPrice();
        emit CollateralAdded(msg.sender, msg.value, price);
    }

    function withdrawCollateral(uint256 amount) public {
        if (amount == 0) {
            revert Lending__InvalidAmount();
        }
        
        if (s_userCollateral[msg.sender] < amount) {
            revert Lending__InvalidAmount(); 
        }

        s_userCollateral[msg.sender] -= amount;
        _validatePosition(msg.sender);

        uint256 price = i_cornDEX.getEthPrice();
        emit CollateralWithdrawn(msg.sender, amount, price);

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert Lending__TransferFailed();
        }
    }

    function calculateCollateralValue(address user) public view returns (uint256) {
        uint256 ethPrice = i_cornDEX.getEthPrice(); 
        uint256 ethAmount = s_userCollateral[user];
        return (ethAmount * ethPrice) / 1e18;
    }

    function _calculatePositionRatio(address user) internal view returns (uint256) {
        uint256 collateralValue = calculateCollateralValue(user);
        uint256 borrowedValue = s_userBorrowed[user];

        if (borrowedValue == 0) {
            return type(uint256).max; 
        }
        return (collateralValue * 100) / borrowedValue;
    }

    function isLiquidatable(address user) public view returns (bool) {
        uint256 positionRatio = _calculatePositionRatio(user);
        return positionRatio < COLLATERAL_RATIO;
    }

    function _validatePosition(address user) internal view {
        uint256 positionRatio = _calculatePositionRatio(user);
        if (positionRatio < COLLATERAL_RATIO) {
            revert Lending__UnsafePositionRatio();
        }
    }

    function borrowCorn(uint256 borrowAmount) public {
        if (borrowAmount == 0) {
            revert Lending__InvalidAmount();
        }

        s_userBorrowed[msg.sender] += borrowAmount;
        _validatePosition(msg.sender);

        uint256 price = i_cornDEX.getEthPrice();
        emit AssetBorrowed(msg.sender, borrowAmount, price);

        bool success = i_corn.transfer(msg.sender, borrowAmount);
        if (!success) {
            revert Lending__BorrowingFailed();
        }
    }

    function repayCorn(uint256 repayAmount) public {
        if (repayAmount == 0) {
            revert Lending__InvalidAmount();
        }
        if (s_userBorrowed[msg.sender] < repayAmount) {
             revert Lending__InvalidAmount(); 
        }

        bool success = i_corn.transferFrom(msg.sender, address(this), repayAmount);
        if (!success) {
            revert Lending__RepayingFailed();
        }

        s_userBorrowed[msg.sender] -= repayAmount;
        
        uint256 price = i_cornDEX.getEthPrice();
        emit AssetRepaid(msg.sender, repayAmount, price);
    }

    function liquidate(address user) public {
        if (!isLiquidatable(user)) {
            revert Lending__NotLiquidatable();
        }

        uint256 debtAmount = s_userBorrowed[user];
        uint256 ethPrice = i_cornDEX.getEthPrice();

        if (i_corn.balanceOf(msg.sender) < debtAmount) {
            revert Lending__InsufficientLiquidatorCorn();
        }

        uint256 ethValue = (debtAmount * 1e18) / ethPrice;
        uint256 rewardAmount = (ethValue * LIQUIDATOR_REWARD) / 100;
        uint256 totalCollateralToLiquidator = ethValue + rewardAmount;

        if (totalCollateralToLiquidator > s_userCollateral[user]) {
            totalCollateralToLiquidator = s_userCollateral[user];
        }

        bool success = i_corn.transferFrom(msg.sender, address(this), debtAmount);
        if (!success) {
            revert Lending__RepayingFailed();
        }

        s_userBorrowed[user] = 0;
        s_userCollateral[user] -= totalCollateralToLiquidator;

        emit Liquidation(user, msg.sender, totalCollateralToLiquidator, debtAmount, ethPrice);
        
        (bool ethSent, ) = payable(msg.sender).call{value: totalCollateralToLiquidator}("");
        if (!ethSent) {
            revert Lending__TransferFailed();
        }
    }
}