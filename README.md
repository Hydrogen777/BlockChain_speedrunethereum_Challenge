# SpeedRunEthereum – Challenges 1–6 (Summary)

## Challenge 1: Decentralized Staking App

**Link:** https://speedrunethereum.com/challenge/decentralized-staking  

### Mô tả
Xây dựng một ứng dụng gây quỹ bằng smart contract:
- Người dùng gửi ETH vào contract.
- Nếu tổng ETH đạt mục tiêu trước thời hạn, tiền sẽ được gửi sang contract khác.
- Nếu không đạt mục tiêu và đã hết thời gian, người dùng có thể rút lại ETH.

### File chính
- `Staker.sol`

### Chức năng chính
- `stake()`: gửi ETH vào contract.
- `execute()`: kiểm tra điều kiện và thực hiện gửi tiền nếu đủ yêu cầu.
- `withdraw()`: rút ETH khi gây quỹ thất bại.
- `timeLeft()`: trả về thời gian còn lại.

---

## Challenge 2: Token Vendor

**Link:** https://speedrunethereum.com/challenge/token-vendor  

### Mô tả
Tạo một token ERC20 và một contract cho phép mua/bán token bằng ETH.

### File chính
- `YourToken.sol`
- `Vendor.sol`

### Chức năng chính
- Mua token bằng ETH (`buyTokens`).
- Bán token để nhận ETH (`sellTokens`).
- Người dùng cần `approve()` trước khi bán token.
- Chủ contract có thể rút ETH (`withdraw`).

---

## Challenge 3: Dice Game

**Link:** https://speedrunethereum.com/challenge/dice-game  

### Mô tả
Khai thác lỗi tạo số ngẫu nhiên trên blockchain để luôn thắng game xúc xắc.

### File chính
- `DiceGame.sol`
- `RiggedRoll.sol`

### Ý chính
- Game sử dụng `blockhash(block.number - 1)` để tạo số ngẫu nhiên.
- Giá trị này có thể đoán được trong cùng block.
- Contract tấn công chỉ chơi khi chắc chắn thắng, nếu thua thì hủy giao dịch.

---

## Challenge 4: Build a DEX (AMM)

**Link:** https://speedrunethereum.com/challenge/dex  

### Mô tả
Xây dựng một sàn giao dịch phi tập trung đơn giản theo mô hình AMM.

### File chính
- `DEX.sol`

### Chức năng chính
- Swap giữa ETH và Token.
- Áp dụng công thức định giá dựa trên lượng tài sản trong pool.
- Thêm thanh khoản (`deposit`) và nhận LP token.
- Rút thanh khoản (`withdraw`) bằng cách đốt LP token.

---

## Challenge 5: Over-Collateralized Lending

**Link:** https://speedrunethereum.com/challenge/over-collateralized-lending  

### Mô tả
Xây dựng hệ thống cho vay có thế chấp, tương tự các nền tảng DeFi phổ biến.

### File chính
- `Lending.sol` hoặc `Vault.sol`

### Chức năng chính
- Gửi tài sản thế chấp (`deposit`).
- Vay tài sản khác dựa trên giá trị thế chấp (`borrow`).
- Trả nợ (`repay`).
- Thanh lý vị thế không an toàn (`liquidate`).

---

## Challenge 6: Stablecoins

**Link:** https://speedrunethereum.com/challenge/stablecoins  

### Mô tả
Tạo một stablecoin được bảo chứng bằng ETH, hoạt động tương tự DAI.

### File chính
- `DecentralizedStableCoin.sol`
- `DSCEngine.sol`

### Chức năng chính
- Gửi ETH để mint stablecoin.
- Trả stablecoin để lấy lại ETH.
- Sử dụng Oracle để lấy giá ETH.
- Đảm bảo tài sản thế chấp luôn lớn hơn giá trị stablecoin đã mint.

---


