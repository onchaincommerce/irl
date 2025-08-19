# IRL - Instant Value Transfer App Clip

IRL lets two strangers bring their iPhones together and transfer value. A tiny **App Clip** on each phone exchanges a one‑time **claim token** over **MultipeerConnectivity** (Bluetooth preferred), the receiver authenticates with **CDP Embedded Wallets (OTP)**, and funds are released from an on‑chain **ClaimVault** to their new self‑custody wallet — **no installs, no seed phrases, no gas**.

## 🚀 Current Status

### ✅ Completed
- [x] iOS App Clip target structure created
- [x] MultipeerConnectivity service implemented (Bluetooth-first)
- [x] Sender/Receiver UI flows implemented
- [x] Next.js web app with CDP SDK integration
- [x] API routes for claim creation/retrieval
- [x] ClaimVault smart contract (Base Sepolia ready)
- [x] Foundry configuration for contract deployment

### 🔄 In Progress
- [ ] CDP Embedded Wallets integration in claim page
- [ ] Smart contract deployment to Base Sepolia
- [ ] End-to-end testing

### 📋 Next Steps
- [ ] Deploy ClaimVault to Base Sepolia
- [ ] Integrate CDP Embedded Wallets in web claim page
- [ ] Connect iOS App Clip to web API
- [ ] Test Multipeer handoff between two devices
- [ ] Deploy web app to Vercel

## 🏗️ Project Structure

```
IRL/
├── IRL/                    # Main iOS App
├── IRLClip/               # App Clip Target
│   ├── IRLClipApp.swift
│   ├── ClipContentView.swift
│   ├── MultipeerService.swift
│   └── Info.plist
├── apps/
│   └── web/               # Next.js Web App
│       ├── src/app/
│       │   ├── api/claims/ # API routes
│       │   └── claim/[id]/ # Claim page
│       └── .env.local
├── packages/
│   └── contracts/         # Smart Contracts
│       ├── src/ClaimVault.sol
│       └── foundry.toml
└── IRL_PRD.md            # Product Requirements
```

## 🧪 Testing the App Clip

### Prerequisites
- Two iOS devices with iOS 14+
- Xcode project opened in Cursor
- App Clip target added to project

### Steps to Test
1. **Add App Clip Target in Xcode:**
   - Open `IRL.xcodeproj` in Xcode
   - File → New → Target → App Clip
   - Name: `IRLClip`
   - Bundle ID: `com.yourcompany.IRL.Clip`

2. **Add Source Files:**
   - Add `IRLClip/` folder to the App Clip target
   - Ensure all Swift files are included in target membership

3. **Configure Entitlements:**
   - Add Associated Domains entitlement
   - Add Local Network usage description
   - Add Bonjour services

4. **Test on Device:**
   - Run App Clip target on one device
   - Test Multipeer discovery and handoff

## 🌐 Web App Development

### Local Development
```bash
cd apps/web
npm run dev
```

### Environment Variables
```bash
NEXT_PUBLIC_CDP_PROJECT_ID=a682660c-14ce-4191-a528-c0a53fd42a2e
```

### API Endpoints
- `POST /api/claims` - Create new claim
- `GET /api/claims?claimId={id}` - Get claim details

## 📱 App Clip Features

### Sender Flow
1. Enter USDC amount
2. Create bump (generates claim)
3. Start Multipeer advertising
4. Send claim data to receiver
5. Show QR fallback

### Receiver Flow
1. Launch App Clip (via link/QR)
2. Start Multipeer browsing
3. Receive claim data
4. Open web claim page
5. Authenticate with CDP
6. Claim funds

### Multipeer Service
- **Service Type:** `irl-bump-v1`
- **Transport:** Bluetooth preferred, Wi-Fi fallback
- **Encryption:** Required
- **Timeout:** 10s discovery, 5s send
- **Auto-accept:** First invitation

## 🔒 Security Features

- 128-bit random secrets
- Only secretHash stored on-chain
- 24-hour expiry with refund capability
- Race-safe claim processing
- Reentrancy protection

## 🚀 Deployment

### Smart Contract
```bash
cd packages/contracts
forge build
forge deploy --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY
```

### Web App
```bash
cd apps/web
npm run build
# Deploy to Vercel
```

## 📚 Resources

- [CDP Documentation](https://docs.cdp.coinbase.com/)
- [MultipeerConnectivity Guide](https://developer.apple.com/documentation/multipeerconnectivity)
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet)
- [Foundry Book](https://book.getfoundry.sh/)

## 🤝 Contributing

This is a focused MVP implementation. Key areas for improvement:
- Database integration (replace in-memory storage)
- Error handling and user feedback
- UI/UX polish
- Testing coverage
- Gas optimization

---

**Note:** This project uses Base Sepolia for development. Switch to Base mainnet for production deployment.
