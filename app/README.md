# Staking Farm Frontend

React-based frontend for the Staking Farm smart contract.

## Features

- ✅ **Wallet Connection**: Connect to Web3 wallets using RainbowKit
- ✅ **Network Support**: Configured for Sepolia testnet
- ✅ **Modern UI**: Built with React, TypeScript, and Tailwind CSS
- 🔄 **Staking Interface**: Coming in next phase
- 🔄 **Reward Management**: Coming in next phase

## Setup

### Prerequisites

- Node.js (v20 or higher)
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

### Environment Variables

Create a `.env` file in the app directory:

```bash
# Get from https://cloud.walletconnect.com
VITE_WALLET_CONNECT_PROJECT_ID=your_project_id_here
```

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Project Structure

```
app/
├── src/
│   ├── components/
│   │   ├── ConnectWallet.tsx    # Wallet connection screen
│   │   └── WalletStatus.tsx     # Connected wallet info
│   ├── config/
│   │   └── wagmi.ts             # Wagmi configuration
│   ├── App.tsx                  # Main app component
│   └── main.tsx                 # App entry point
├── tailwind.config.js           # Tailwind configuration
└── package.json                 # Dependencies
```

## Next Steps

1. **Get WalletConnect Project ID**: Visit [cloud.walletconnect.com](https://cloud.walletconnect.com) to get your project ID
2. **Deploy Contracts**: Deploy the staking farm contracts to Sepolia
3. **Add Contract Integration**: Connect the frontend to the deployed contracts
4. **Implement Staking Features**: Add stake, unstake, and claim functionality

## Technologies Used

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Wagmi** - React hooks for Ethereum
- **RainbowKit** - Wallet connection UI
- **Viem** - Ethereum client
