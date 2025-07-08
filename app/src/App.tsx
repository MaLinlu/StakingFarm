import { WalletStatus } from './components/WalletStatus';
import { ConnectWallet } from './components/ConnectWallet';
import { StakingInterface } from './components/StakingInterface';
import { useAccount } from 'wagmi';

function App() {
  const { isConnected } = useAccount();

  if (!isConnected) {
    return <ConnectWallet />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <header className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Staking Farm
          </h1>
          <p className="text-gray-600">
            Stake your tokens and earn rewards
          </p>
        </header>

        <WalletStatus />

        <StakingInterface />
      </div>
    </div>
  );
}

export default App;
