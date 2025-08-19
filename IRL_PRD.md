# IRL — App Clip ↔ App Clip “Bump” (MultipeerConnectivity over Bluetooth) — PRD (Focused)

## 0) One‑liner
IRL lets two strangers bring their iPhones together and transfer value. A tiny **App Clip** on each phone exchanges a one‑time **claim token** over **MultipeerConnectivity** (Bluetooth preferred), the receiver authenticates with **CDP Embedded Wallets (OTP)**, and funds are released from an on‑chain **ClaimVault** to their new self‑custody wallet — **no installs, no seed phrases, no gas**.

---

## 0.1) Project setup — start here
- **Start an iOS App** project in Xcode and **add an App Clip target** (App Clips are attached to an app). During development you can run just the App Clip.
- **Invocation (MVP):** links/QR only (no NFC tags). Your QR/link opens `https://irl.app/claim/{claimId}` which invokes the App Clip experience.
- **Bundle capabilities (App Clip target):** Associated Domains (for universal links), Local Network usage description, Bonjour services disclosure; Bluetooth is used implicitly by MultipeerConnectivity.

---

## 1) Core user flows
### 1.1 Sender (S)
1) Open App Clip → Enter amount (USDC) → **Create bump**.  
2) Client calls `POST /api/claims` → receives `{claimId, secret, expiry}`.  
3) Client signs **approve(USDC → ClaimVault)** and **deposit(claimId, secretHash, amount, expiry)** with **sponsored gas**.  
4) App starts **Multipeer advertise** and shows a **fallback QR**.  
5) On peer connect, client **sends payload**: `{claimId, secret, token, amount}`.  
6) UI shows **“Bump sent — waiting for claim”** with countdown and refund-after-expiry.

### 1.2 Receiver (R)
1) Launch App Clip (scan QR / open link) → App starts **Multipeer browse**.  
2) On peer connect, receive payload → show **“You’ve got $X — Claim”**.  
3) **OTP sign‑in** (email or SMS) → **embedded wallet** is created/accessed.  
4) Tap **Claim** → client calls `claim(claimId, secret, receiverAddress)` with **sponsored gas**.  
5) Success screen shows **amount, token, tx hash** and tiny **History** list.

### 1.3 Errors & fallbacks (MVP only)
- **Peer discovery timeout (10s):** show QR fallback; receiver can fetch payload by scanning sender’s QR or by link relay.  
- **Expired:** show “Expired — ask sender to recreate”.  
- **Already claimed:** show receipt.

---

## 2) Architecture (MVP)
**Clients (both S & R):** App Clip (SwiftUI)  
- **Transport:** MultipeerConnectivity (Bluetooth / P2P Wi‑Fi / infra Wi‑Fi; payload <1 KB). QR fallback for reliability.  
- **Wallet UI:** `WKWebView` showing a minimal claim page that runs the **CDP Embedded Wallets Web SDK** (OTP + on‑chain calls via wagmi/viem). JS→Swift bridge for status.

**Web (claim page + API):** Next.js (TypeScript) on Vercel  
- **Wallet SDK:** CDP Embedded Wallets Web SDK + React hooks.  
- **Onchain client:** **wagmi** + **viem**, configured for **Base** (+ Paymaster sponsorship).  
- **API routes:** `/api/claims` (create/get), backed by **InstantDB Admin SDK** (store `secretHash` only) or Postgres.

**On‑chain:** `ClaimVault` on **Base** (dev: Base Sepolia)  
- Minimal `deposit / claim / refund` contract; emit events.

**Gasless:** **CDP Paymaster** sponsors `approve`, `deposit`, and `claim`.

---

## 3) MultipeerConnectivity — implementation notes (Bluetooth‑first)
- **Transports:** Framework auto‑selects (Bluetooth, peer‑to‑peer Wi‑Fi, infrastructure Wi‑Fi). No API to force Bluetooth‑only.  
- **Service type:** ≤15 chars, lowercase/numbers/hyphen, must include a letter (e.g., `irl-bump-v1`).  
- **Advertise/Browse:** Sender uses `MCNearbyServiceAdvertiser`; Receiver uses `MCNearbyServiceBrowser`. Auto‑accept first invitation; tear down after send.  
- **Session:** `MCSession(encryptionPreference: .required)`; send a single JSON blob; add HMAC over payload.  
- **Timeouts:** 10s discovery, 5s send; fallback to QR.  
- **Info.plist (App Clip):** `NSLocalNetworkUsageDescription` + `NSBonjourServices` (list your service type) so discovery works without denial prompts.

**Peer payload schema**
```json
{ "v":1, "claimId":"…", "secret":"base64(16 bytes)", "token":"USDC", "amount":1.00 }
```

---

## 4) CDP Embedded Wallets — what we rely on
- **OTP auth (email/SMS):** creates/opens the wallet inline; **multi‑device up to 5**.  
- **Web SDK in App Clip:** Host a light claim page that mounts the CDP Web SDK (AuthButton/hooks) inside a WKWebView. After OTP, expose `receiverAddress` via JS bridge and call `claim`.  
- **Send/Receive primitives:** Calls hit our `ClaimVault` for locked transfers.  
- **Gas sponsorship:** Configure **Base Paymaster** so `approve`, `deposit`, and `claim` are covered.  
- **Domain allowlist:** Add your claim page domain in the CDP portal before testing.

---

## 5) Security & abuse controls
- **Secrets:** 128‑bit random; store only `secretHash`; invalidate on claim/refund.  
- **Expiry:** Default 24h; sender UI shows countdown and enables refund when elapsed.  
- **Rate limits:** per‑sender cap, per‑IP/email throttles; CAPTCHA on claim creation.  
- **Race safety:** First valid `claim(secret, receiver)` wins; contract marks `Claimed` and blocks repeats.  
- **Asset scope:** Single USDC contract on Base for MVP to simplify risk.

---

## 6) iOS configuration (copy‑paste)
**Info.plist keys (App Clip target)**  
- `NSLocalNetworkUsageDescription` = “IRL discovers nearby iPhones to hand off a claim token for value transfer.”  
- `NSBonjourServices` = `[ "_irl-bump._tcp" ]` (match your service type)  
- Associated Domains entitlement = `[ "applinks:irl.app" ]` (URL invocation)

**ServiceType string rules**  
- 1–15 chars, lowercase letters/numbers/hyphen; no leading/trailing/double hyphens. Example: `irl-bump-v1`.

---

## 7) The single most ideal stack (opinionated)
- **iOS handoff:** SwiftUI **App Clip** + **MultipeerConnectivity** (Bluetooth‑first) + **WKWebView** to show the claim page.  
- **Web:** **Next.js (App Router) + TypeScript** with **wagmi + viem** and **CDP Embedded Wallets Web SDK** (AuthButton/hooks).  
- **Contracts:** **Foundry** (forge/anvil/cast) for `ClaimVault` on **Base** (dev: Base Sepolia).  
- **Gasless:** **CDP Paymaster** sponsorship configured in wagmi/viem.  
- **DB:** **InstantDB** via **Admin SDK** in API routes (store `secretHash` only) — or Postgres for SQL fans.

---

## 8) Quick build checklist — order of operations
1) **Create repo & workspace**  
   - Make a **private GitHub repo** (monorepo). `git clone` locally.  
   - In the repo root: create `apps/ios`, `apps/web`, `packages/contracts` directories.
2) **iOS scaffolding**  
   - In Xcode, create an **iOS App** in `apps/ios` → then **add an App Clip target**.  
   - Add entitlements: **Associated Domains**; Info.plist: `NSLocalNetworkUsageDescription`, `NSBonjourServices`.  
   - Commit.
3) **Web scaffolding**  
   - `pnpm dlx create-next-app apps/web` (TypeScript, App Router).  
   - Install **wagmi**, **viem**, and the **CDP Web SDK**/**hooks**.  
   - Commit.
4) **Contracts**  
   - `foundryup && forge init packages/contracts`.  
   - Implement `ClaimVault.sol`; write 1–2 unit tests; commit.
5) **CDP & Base**  
   - Create a **CDP project**; enable **Embedded Wallets** + **Paymaster**.  
   - Add your claim page domain to **CDP domain allowlist**.  
   - Configure **Base Sepolia** RPC + **Paymaster URL** in the web app (wagmi).  
   - Commit env templates.
6) **Deploy contracts**  
   - Deploy `ClaimVault` to **Base Sepolia** with Foundry; add address to web env.  
   - Commit deployment script + addresses JSON.
7) **Backend / DB**  
   - In Next.js, add **API routes**: `POST /api/claims`, `GET /api/claims/:id`.  
   - Use **InstantDB Admin SDK** (or Postgres) to store `{claimId, secretHash, amount, token, sender, expiry, status}`; never store plaintext `secret`.  
   - Commit.
8) **Web claim page**  
   - Build `/claim/[id]` route: mount **CDP Web SDK** (OTP), then call `claim(claimId, secret, receiverAddr)` via **wagmi/viem** with **sponsored gas**.  
   - Post `txHash` to Swift via `window.webkit.messageHandlers` bridge; show success.  
   - Commit.
9) **App Clip flows**  
   - Implement Sender screen: amount → create claim → approve+deposit (sponsored) → start advertise → display QR fallback.  
   - Implement Receiver screen: browse → receive payload → open WKWebView to claim page.  
   - Commit.
10) **End‑to‑end smoke (Sepolia)**  
   - Two iPhones: sender → receiver; OTP → claim; verify tx on Basescan.  
   - Commit tags: `v0.1.0‑poc`.
11) **Pilot prep**  
   - Add refund after expiry, basic activity view, and promo pool caps. Switch RPC to **Base mainnet** when ready.

---

## 9) On‑Chain Contract — `ClaimVault.sol` (minimal)
**Interface**
```solidity
pragma solidity ^0.8.24;

contract ClaimVault {
  enum Status { None, Pending, Claimed, Refunded }
  struct Claim { address sender; address token; uint128 amount; uint40 expiry; Status status; bytes32 secretHash; }

  event ClaimCreated(bytes32 indexed claimId, address indexed sender, address token, uint256 amount, uint40 expiry);
  event Claimed(bytes32 indexed claimId, address indexed receiver);
  event Refunded(bytes32 indexed claimId);

  function deposit(bytes32 claimId, address token, uint256 amount, bytes32 secretHash, uint40 expiry) external;
  function claim(bytes32 claimId, bytes calldata secret, address receiver) external;
  function refund(bytes32 claimId) external;
}
```

---

## 10) Sequence — Happy Path (text)
```
S(App Clip)  →  Backend  →  ClaimVault  ←  R(App Clip)
  |  createClaim()          |                       |
  |←{id,secret,expiry}      |                       |
  | approve+deposit         |→ lock funds           |
  | start peer advertise    |                       | start peer browse
  | ————(secret,id) ——————>|                       | (Multipeer)
  |                         |                       | OTP → create wallet
  |                         |                       | claim(id, secret, addr)
  |                         | ←——————— funds ——————|
```
