import { useAccount, useBalance } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export const WalletStatus = () => {
  const { address, isConnected } = useAccount();
  const { data: balance } = useBalance({
    address,
  });

  if (!isConnected) {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-medium text-yellow-800">
              Wallet Not Connected
            </h3>
            <p className="text-yellow-700">
              Please connect your wallet to interact with the staking farm
            </p>
          </div>
          <ConnectButton />
        </div>
      </div>
    );
  }

  return (
    <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-medium text-green-800">
            Wallet Connected
          </h3>
          <p className="text-green-700 text-sm">
-            Address: {address?.slice(0, 6)}...{address?.slice(-4)}
+            Address: {address && address.length > 10 ? `${address.slice(0, 6)}...${address.slice(-4)}` : address}
          </p>
          {balance && (
            <p className="text-green-700 text-sm">
              Balance: {parseFloat(balance.formatted).toFixed(4)} {balance.symbol}
            </p>
          )}
        </div>
        <ConnectButton />
      </div>
    </div>
  );
}; 