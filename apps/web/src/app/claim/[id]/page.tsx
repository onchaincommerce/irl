'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { cdpService, WalletUser } from '@/lib/cdp-service';

function ClaimPage() {
  const params = useParams();
  const claimId = params.id as string;
  const [claimData, setClaimData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // SMS OTP states
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [showOTPInput, setShowOTPInput] = useState(false);
  const [isSendingSMS, setIsSendingSMS] = useState(false);
  const [isVerifyingOTP, setIsVerifyingOTP] = useState(false);
  const [walletUser, setWalletUser] = useState<WalletUser | null>(null);
  const [smsMessage, setSmsMessage] = useState('');

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

  const handleSendSMS = async () => {
    if (!phoneNumber.trim()) {
      setError('Please enter a valid phone number');
      return;
    }

    setIsSendingSMS(true);
    setError('');

    try {
      const result = await cdpService.initializeWallet(phoneNumber.trim());
      
      if (result.success) {
        setShowOTPInput(true);
        setSmsMessage(result.message);
      } else {
        setError(result.message);
      }
    } catch (err) {
      setError('Failed to send SMS code');
    } finally {
      setIsSendingSMS(false);
    }
  };

  const handleVerifyOTP = async () => {
    if (!otp.trim() || otp.length !== 6) {
      setError('Please enter a valid 6-digit code');
      return;
    }

    setIsVerifyingOTP(true);
    setError('');

    try {
      const result = await cdpService.verifyOTPAndCreateWallet(phoneNumber.trim(), otp.trim());
      
      if (result.success && result.user) {
        setWalletUser(result.user);
        setSmsMessage(result.message);
        // TODO: Proceed with claiming the funds
      } else {
        setError(result.message);
      }
    } catch (err) {
      setError('Failed to verify OTP');
    } finally {
      setIsVerifyingOTP(false);
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
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    placeholder="+1 (555) 123-4567"
                    className="w-full px-3 py-2 border border-blue-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    disabled={showOTPInput}
                  />
                </div>
                
                <button 
                  onClick={handleSendSMS}
                  disabled={isSendingSMS || !phoneNumber.trim()}
                  className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors disabled:bg-blue-400 disabled:cursor-not-allowed"
                >
                  {isSendingSMS ? (
                    <span className="flex items-center justify-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Sending...
                    </span>
                  ) : (
                    'Send SMS Code'
                  )}
                </button>
              </div>
              
              {/* OTP Input */}
              {showOTPInput && (
                <div className="mt-4 space-y-3">
                  <div>
                    <label htmlFor="otp" className="block text-sm font-medium text-blue-900 mb-1">
                      Enter 6-digit code
                    </label>
                    <input
                      type="text"
                      id="otp"
                      value={otp}
                      onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      placeholder="123456"
                      maxLength={6}
                      className="w-full px-3 py-2 border border-blue-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-center text-lg tracking-widest"
                    />
                  </div>
                  
                  <button 
                    onClick={handleVerifyOTP}
                    disabled={isVerifyingOTP || otp.length !== 6}
                    className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 transition-colors disabled:bg-green-400 disabled:cursor-not-allowed"
                  >
                    {isVerifyingOTP ? (
                      <span className="flex items-center justify-center">
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                        Verifying...
                      </span>
                    ) : (
                      'Verify & Create Wallet'
                    )}
                  </button>
                </div>
              )}
              
              {/* Error Message */}
              {error && (
                <div className="mt-4 p-3 bg-red-100 border border-red-300 rounded-md">
                  <p className="text-red-800 text-sm">{error}</p>
                </div>
              )}
              
              {/* Success Message */}
              {smsMessage && (
                <div className="mt-4 p-3 bg-green-100 border border-green-300 rounded-md">
                  <p className="text-green-800 text-sm">{smsMessage}</p>
                </div>
              )}
              
              {/* Wallet Created Success */}
              {walletUser && (
                <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-md">
                  <h4 className="text-green-900 font-semibold mb-2">Wallet Created Successfully!</h4>
                  <p className="text-green-700 text-sm mb-2">Address: {walletUser.address}</p>
                  <p className="text-green-700 text-sm">You can now claim your USDC!</p>
                </div>
              )}
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

export default ClaimPage;
