# 🥩 Challenge 1: Decentralized Staking App

Đây là Challenge 1 của **Ethereum Speed Run** - một ứng dụng staking phi tập trung đơn giản được xây dựng với **Scaffold-ETH 2**.

## 📖 Tổng quan

Ứng dụng này cho phép người dùng:
- **Stake ETH** vào một smart contract
- Nếu đạt **threshold 1 ETH** trước **deadline 72 giờ** → ETH được gửi đến External Contract
- Nếu KHÔNG đạt threshold → Người dùng có thể **withdraw** lại ETH của họ

## 🏗 Cấu trúc Project

```
challenge-decentralized-staking/
├── packages/
│   ├── hardhat/              # Smart contracts
│   │   ├── contracts/
│   │   │   ├── Staker.sol                    # Main staking contract
│   │   │   └── ExampleExternalContract.sol   # Target contract
│   │   ├── deploy/
│   │   │   └── 00_deploy_staker.ts
│   │   └── test/
│   │       └── Staker.ts                     # Test suite
│   └── nextjs/               # Frontend
│       ├── app/
│       └── components/
├── package.json
└── README.md
```

## 🎯 Smart Contract Features

### Staker.sol

**State Variables:**
- `threshold`: 1 ETH (constant)
- `deadline`: 72 giờ từ lúc deploy
- `balances`: mapping theo dõi số ETH mỗi user stake
- `openForWithdraw`: flag cho phép withdraw

**Functions:**
- `stake()` - Stake ETH vào contract
- `execute()` - Thực thi sau deadline (complete hoặc mở withdraw)
- `withdraw()` - Rút ETH nếu không đạt threshold
- `timeLeft()` - Xem thời gian còn lại
- `metThreshold()` - Check đã đạt threshold chưa

**Events:**
- `Stake(address indexed sender, uint256 amount)` - Emit khi stake
- `Withdraw(address indexed sender, uint256 amount)` - Emit khi withdraw

**Security Features:**
- ✅ Reentrancy protection (Checks-Effects-Interactions pattern)
- ✅ Balance update trước external call
- ✅ Proper deadline và threshold checks

## 🚀 Hướng dẫn Setup

### Prerequisites

- **Node.js** >= v20.18.3
- **Yarn** v3.2.3
- **Git**

### Bước 1: Clone & Install

```bash
# Di chuyển vào thư mục project
cd challenge-decentralized-staking

# Install dependencies
yarn install
```

### Bước 2: Chạy Local Blockchain

```bash
# Terminal 1: Chạy local Hardhat node
yarn chain
```

Lệnh này sẽ:
- Khởi động local blockchain trên `http://127.0.0.1:8545`
- Tạo test accounts với ETH
- Hiển thị private keys để import vào MetaMask

### Bước 3: Deploy Contracts

```bash
# Terminal 2: Deploy contracts
yarn deploy
```

Lệnh này sẽ deploy:
1. `ExampleExternalContract.sol`
2. `Staker.sol` (với address của ExampleExternalContract)

### Bước 4: Start Frontend

```bash
# Terminal 3: Chạy Next.js frontend
yarn start
```

Frontend sẽ chạy tại: `http://localhost:3000`

## 🧪 Testing

### Chạy tất cả tests

```bash
yarn test
```

hoặc

```bash
yarn hardhat:test
```

### Test Cases

Tests kiểm tra:
1. ✅ Deploy contracts thành công
2. ✅ Stake tăng balance
3. ✅ Execute thành công khi đạt threshold
4. ✅ Withdraw thành công khi không đạt threshold
5. ✅ Gas cost accounting

### Run tests với coverage

```bash
yarn workspace @se-2/hardhat coverage
```

## 🌐 Deploy lên Testnet (Sepolia)

### Bước 1: Tạo/Import Account

```bash
# Tạo account mới
yarn account:generate

# Hoặc import existing account
yarn account:import
```

### Bước 2: Lấy Testnet ETH

1. Copy địa chỉ account của bạn
2. Lấy ETH từ faucets:
   - https://sepoliafaucet.com/
   - https://www.infura.io/faucet/sepolia
   - https://faucet.quicknode.com/ethereum/sepolia

### Bước 3: Setup Environment Variables

Tạo file `.env` trong `packages/hardhat/`:

```env
DEPLOYER_PRIVATE_KEY=your_private_key_here
ALCHEMY_API_KEY=your_alchemy_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Bước 4: Deploy lên Sepolia

```bash
yarn deploy --network sepolia
```

### Bước 5: Verify Contracts

```bash
yarn verify --network sepolia
```

## 🏆 Submit Challenge

### Bước 1: Kiểm tra Contract

Đảm bảo contract của bạn:
- ✅ Deploy thành công lên Sepolia
- ✅ Verified trên Etherscan
- ✅ Có đầy đủ functions: `stake()`, `execute()`, `withdraw()`, `timeLeft()`, `metThreshold()`
- ✅ Events: `Stake` và `Withdraw`

### Bước 2: Test Contract trên Testnet

```bash
# Chạy tests trên deployed contract
CONTRACT_ADDRESS=0xYourContractAddress yarn test --network sepolia
```

### Bước 3: Submit lên SpeedRunEthereum

1. Truy cập: https://speedrunethereum.com/
2. Connect wallet (sử dụng account đã deploy)
3. Chọn **Challenge #1: Decentralized Staking**
4. Nhập **contract address** trên Sepolia
5. Click **Submit**

### Bước 4: Đợi Auto-grader

Auto-grader sẽ kiểm tra:
- ✅ Contract có đúng interface không
- ✅ Functions hoạt động đúng không
- ✅ Events được emit đúng không
- ✅ Logic staking/withdraw đúng spec

Nếu **PASS** → Bạn nhận được **NFT Badge**! 🎉

## 📝 Available Scripts

### Root Level

```bash
yarn chain           # Chạy local Hardhat node
yarn deploy          # Deploy contracts
yarn start           # Chạy frontend
yarn test            # Chạy tests
yarn compile         # Compile contracts
yarn account:generate # Tạo new account
yarn verify          # Verify contracts
```

### Hardhat Workspace

```bash
yarn hardhat:test          # Chạy tests
yarn hardhat:compile       # Compile contracts
yarn hardhat:deploy        # Deploy contracts
yarn hardhat:verify        # Verify on Etherscan
yarn hardhat:clean         # Clean artifacts
yarn hardhat:flatten       # Flatten contracts
```

### Next.js Workspace

```bash
yarn next:build      # Build production
yarn next:serve      # Serve production build
yarn next:lint       # Run linter
yarn next:format     # Format code
```

## 🎨 Frontend Usage

### Connect Wallet

1. Click **Connect Wallet**
2. Chọn MetaMask
3. Approve connection

### Stake ETH

1. Nhập số lượng ETH muốn stake
2. Click **Stake**
3. Confirm transaction trong MetaMask

### Check Status

- **Time Left**: Countdown timer
- **Total Staked**: Tổng ETH trong contract
- **Your Balance**: Số ETH bạn đã stake
- **Threshold Progress**: Progress bar đến 1 ETH

### Execute (sau deadline)

1. Đợi deadline hết
2. Click **Execute**
3. Nếu đạt threshold → ETH gửi đến External Contract
4. Nếu không → Withdraw được mở

### Withdraw

1. Chỉ available nếu không đạt threshold
2. Click **Withdraw**
3. Nhận lại ETH đã stake (trừ gas)

## 🔍 Debug UI

Scaffold-ETH 2 có built-in debug tools:

- **Contract UI**: Tương tác trực tiếp với functions
- **Events**: Xem tất cả events được emit
- **Contract Debug**: Inspect storage variables

Truy cập tại: `http://localhost:3000/debug`

## 📚 Documentation

- **Scaffold-ETH 2**: https://docs.scaffoldeth.io/
- **Hardhat**: https://hardhat.org/docs
- **Next.js**: https://nextjs.org/docs
- **Speed Run Ethereum**: https://speedrunethereum.com/

## 🐛 Troubleshooting

### Port đã được sử dụng

```bash
# Kill process trên port 3000
npx kill-port 3000

# Kill process trên port 8545
npx kill-port 8545
```

### Contract không deploy

```bash
# Clean và rebuild
yarn hardhat:clean
yarn compile
yarn deploy
```

### Frontend không connect được

1. Check MetaMask đang ở đúng network
   - Local: `http://127.0.0.1:8545` (Chain ID: 31337)
   - Sepolia: Sepolia test network
2. Import account từ local node vào MetaMask
3. Hard refresh browser (Ctrl+Shift+R)

### Tests fail

```bash
# Restart local chain
# Terminal 1
yarn chain

# Terminal 2
yarn deploy
yarn test
```

## 🎓 Learning Resources

### Solidity Concepts

- **Mappings**: Lưu trữ balances
- **Events**: Tracking on-chain actions
- **Modifiers**: Access control
- **Time**: `block.timestamp`, deadline
- **Ether units**: wei, gwei, ether
- **Security**: Reentrancy protection

### Web3 Integration

- **ethers.js**: Tương tác với blockchain
- **React Hooks**: `useScaffoldReadContract`, `useScaffoldWriteContract`
- **Wallet Connection**: RainbowKit
- **Contract ABIs**: Type-safe contract calls

## 🤝 Contributing

Nếu tìm thấy bugs hoặc muốn cải thiện:

1. Fork repo
2. Tạo branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Tạo Pull Request

## 📄 License

MIT License

## 🙏 Acknowledgments

- **Scaffold-ETH**: Framework tuyệt vời
- **BuidlGuidl**: Community support
- **Austin Griffith**: Creator của Speed Run Ethereum

## 💬 Support

- **Discord**: BuidlGuidl Discord
- **Telegram**: Speed Run Ethereum group
- **GitHub Issues**: Báo bugs tại repo

---

**Good luck với Challenge! 🚀**

Built with ❤️ using Scaffold-ETH 2