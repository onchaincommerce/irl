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
          
          {/* CDP Embedded Wallets will be integrated here */}
          <div className="space-y-4">
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
              <div className="text-gray-400 text-4xl mb-2">🔐</div>
              <p className="text-gray-600">
                CDP Embedded Wallets integration coming soon
              </p>
              <p className="text-sm text-gray-500 mt-2">
                This will handle OTP authentication and wallet creation
              </p>
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
