'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { CDPProvider, useCDP } from '@coinbase/cdp-sdk';

function ClaimPage() {
  const params = useParams();
  const claimId = params.id as string;
  const [claimData, setClaimData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (claimId) {
      fetchClaimData(claimId);
    }
  }, [claimId]);

  const fetchClaimData = async (id: string) => {
    try {
      // TODO: Fetch claim data from API
      // For now, simulate with mock data
      setClaimData({
        id,
        amount: 10.00,
        token: 'USDC',
        sender: '0x1234...5678'
      });
    } catch (err) {
      setError('Failed to fetch claim data');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading claim...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error</h1>
          <p className="text-gray-600">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Claim Your USDC</h1>
          <p className="mt-2 text-gray-600">
            You've received a bump from a nearby iPhone
          </p>
        </div>

        {claimData && (
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="text-center">
              <div className="text-4xl font-bold text-green-600 mb-2">
                ${claimData.amount}
              </div>
              <div className="text-lg text-gray-600 mb-4">
                {claimData.token}
              </div>
              <div className="text-sm text-gray-500">
                From: {claimData.sender}
              </div>
            </div>
          </div>
        )}

        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Sign in to claim
          </h2>
          
          {/* CDP Embedded Wallets Integration */}
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-blue-900 mb-3">
                Create Your Wallet
              </h3>
              <p className="text-blue-700 mb-4">
                Sign in with SMS to create your embedded wallet and claim your USDC
              </p>
              
              {/* SMS OTP Input */}
              <div className="space-y-3">
                <div>
                  <label htmlFor="phone" className="block text-sm font-medium text-blue-900 mb-1">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    id="phone"
                    placeholder="+1 (555) 123-4567"
                    className="w-full px-3 py-2 border border-blue-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                
                <button className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors">
                  Send SMS Code
                </button>
              </div>
              
              {/* OTP Input (hidden initially) */}
              <div className="hidden mt-4 space-y-3">
                <div>
                  <label htmlFor="otp" className="block text-sm font-medium text-blue-900 mb-1">
                    Enter 6-digit code
                  </label>
                  <input
                    type="text"
                    id="otp"
                    placeholder="123456"
                    maxLength={6}
                    className="w-full px-3 py-2 border border-blue-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-center text-lg tracking-widest"
                  />
                </div>
                
                <button className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 transition-colors">
                  Verify & Create Wallet
                </button>
              </div>
            </div>
            
            <div className="text-center text-sm text-gray-500">
              <p>Powered by Coinbase Developer Platform</p>
              <p>Your wallet will be created securely and you can claim your USDC</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function ClaimPageWrapper() {
  return (
    <CDPProvider projectId={process.env.NEXT_PUBLIC_CDP_PROJECT_ID!}>
      <ClaimPage />
    </CDPProvider>
  );
}
