//
//  ClipContentView.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI

struct ClipContentView: View {
    @StateObject private var multipeerService = MultipeerService()
    @StateObject private var apiService = APIService()
    @State private var mode: AppMode = .initial
    @State private var amount: String = ""
    @State private var claimData: ClaimData?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCreatingClaim = false
    
    // Sender authentication states
    @State private var isAuthenticated = false
    @State private var walletAddress: String = ""
    @State private var usdcBalance: Double = 0.0
    @State private var isCheckingBalance = false
    
    // SMS OTP states
    @State private var phoneNumber: String = ""
    @State private var otp: String = ""
    @State private var showOTPInput: Bool = false
    @State private var isSendingOTP: Bool = false
    @State private var isVerifyingOTP: Bool = false
    
    enum AppMode {
        case initial
        case sender
        case receiver
        case claiming
        case success
    }
    
    var body: some View {
        ZStack {
            // Graph paper background
            GraphPaperBackground()
            
            VStack(spacing: 0) {
                // Header with app icon
                VStack(spacing: 16) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.1))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 4)
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    Text("IRL")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Instant value transfer between iPhones")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Main content based on mode
                if isAuthenticated {
                    // User is authenticated, show main options
                    authenticatedMainView
                } else {
                    // User needs to authenticate
                    authenticationView
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Powered by Coinbase Developer Platform")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Secure • Fast • Gasless")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Always start with authentication
            mode = .initial
        }
    }
    
        @ViewBuilder
    private var authenticationView: some View {
        VStack(spacing: 32) {
            // Main authentication card
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 16) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Connect Your Wallet")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                // Description
                Text("Sign in with SMS to create your embedded wallet and start sending USDC instantly")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Simple phone number input
                VStack(spacing: 20) {
                    TextField("Phone number", text: $phoneNumber)
                        .font(.title2)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 20)
                    
                    // Send OTP button
                    Button(action: sendOTP) {
                        HStack(spacing: 12) {
                            Image(systemName: "message.fill")
                                .font(.title2)
                            
                            Text("Sign in")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    .disabled(phoneNumber.isEmpty || isSendingOTP)
                }
                
                // Simple OTP input
                if showOTPInput {
                    VStack(spacing: 20) {
                        Text("Enter the 6-digit code")
                            .font(.headline)
                        
                        TextField("123456", text: $otp)
                            .font(.title)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .onChange(of: otp) { _, newValue in
                                if newValue.count == 6 {
                                    verifyOTP()
                                }
                            }
                        
                        Button("Resend Code") {
                            sendOTP()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                }
                
                // Security info
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Secure SMS verification")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        Text("Instant wallet creation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.blue)
                        Text("No seed phrases needed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var authenticatedMainView: some View {
        VStack(spacing: 24) {
            // Wallet info card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Wallet Connected")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Address:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(walletAddress.prefix(6) + "..." + walletAddress.suffix(4))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("USDC Balance:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", usdcBalance))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Action buttons
            VStack(spacing: 16) {
                Button("Send USDC") {
                    mode = .sender
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Receive USDC") {
                    mode = .receiver
                    multipeerService.startBrowsing()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Disconnect Wallet") {
                    disconnectWallet()
                }
                .buttonStyle(DangerButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var senderView: some View {
        VStack(spacing: 20) {
            Text("Send USDC")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Wallet balance display
            VStack(spacing: 8) {
                Text("Available Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("$\(String(format: "%.2f", usdcBalance)) USDC")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Text("$")
                    .font(.title)
                TextField("0.00", text: $amount)
                    .font(.title)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Balance check message
            if let amountValue = Double(amount), amountValue > 0 {
                if amountValue > usdcBalance {
                    Text("Insufficient balance")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                                    Text("Remaining: $\(String(format: "%.2f", usdcBalance - amountValue))")
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
            
            Button(action: createBump) {
                if isCreatingClaim {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Creating...")
                    }
                } else {
                    Text("Create Bump")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(amount.isEmpty || Double(amount) == nil || isCreatingClaim || (Double(amount) ?? 0) > usdcBalance)
            
            if multipeerService.isAdvertising {
                VStack(spacing: 15) {
                    Text("Looking for nearby iPhone...")
                        .foregroundColor(.secondary)
                    
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    // QR Code fallback
                    if let claim = claimData {
                        QRCodeView(url: "https://irl.app/claim/\(claim.claimId)", size: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .frame(width: 200, height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("Generating QR...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                    }
                    
                    Text("Or scan this QR code on the receiver's phone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            
            Button("Back") {
                mode = .initial
                multipeerService.stopAdvertising()
            }
            .buttonStyle(.bordered)
        }
    }
    
    @ViewBuilder
    private var receiverView: some View {
        VStack(spacing: 20) {
            Text("Receive USDC")
                .font(.title2)
                .fontWeight(.semibold)
            
            if multipeerService.isBrowsing {
                VStack(spacing: 15) {
                    Text("Looking for sender...")
                        .foregroundColor(.secondary)
                    
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Bring your iPhone close to the sender's device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            }
            
            if let claim = claimData {
                VStack(spacing: 15) {
                    Text("You've got")
                        .font(.headline)
                    
                    Text("$\(claim.amount, specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(claim.token)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Claim") {
                        mode = .claiming
                        // TODO: Show web view for CDP authentication
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
            }
            
            Button("Back") {
                mode = .initial
                multipeerService.stopBrowsing()
            }
            .buttonStyle(.bordered)
        }
        .onReceive(multipeerService.$receivedData) { data in
            if let data = data {
                handleReceivedClaim(data)
            }
        }
    }
    
    @ViewBuilder
    private var claimingView: some View {
        VStack(spacing: 20) {
            Text("Claiming...")
                .font(.title2)
                .fontWeight(.semibold)
            
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Please wait while we process your claim")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // TODO: Replace with WKWebView for CDP authentication
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 300)
                .cornerRadius(10)
                .overlay(
                    Text("CDP Embedded Wallet\n(Web View)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                )
        }
    }
    
    @ViewBuilder
    private var successView: some View {
        VStack(spacing: 20) {
            Image("irl_demon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                )
            
            Text("Success!")
                .font(.title)
                .fontWeight(.bold)
            
            if let claim = claimData {
                VStack(spacing: 10) {
                    Text("You received")
                        .font(.headline)
                    
                    Text("$\(claim.amount, specifier: "%.2f") \(claim.token)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Transaction: 0x1234...5678")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button("Done") {
                mode = .initial
                claimData = nil
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func sendOTP() {
        guard !phoneNumber.isEmpty else { return }
        
        isSendingOTP = true
        
        // TODO: Implement real CDP SMS sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSendingOTP = false
            showOTPInput = true
        }
    }
    
    private func verifyOTP() {
        guard otp.count == 6 else { return }
        
        isVerifyingOTP = true
        
        // TODO: Implement real CDP OTP verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isVerifyingOTP = false
            isAuthenticated = true
            walletAddress = "0x1234567890abcdef1234567890abcdef12345678"
            usdcBalance = 100.0 // Mock balance
        }
    }
    
    private func disconnectWallet() {
        isAuthenticated = false
        walletAddress = ""
        usdcBalance = 0.0
        mode = .initial
    }
    
    private func createBump() {
        guard let amountValue = Double(amount) else { return }
        
        // Check if user has sufficient balance
        guard amountValue <= usdcBalance else {
            errorMessage = "Insufficient USDC balance. You have $\(String(format: "%.2f", usdcBalance))"
            showingError = true
            return
        }
        
        isCreatingClaim = true
        
        Task {
            do {
                // Create claim via API
                let (claimId, secret, expiry) = try await apiService.createClaim(amount: amountValue)
                
                // Start advertising for peers
                await MainActor.run {
                    multipeerService.startAdvertising()
                    isCreatingClaim = false
                }
                
                // Store claim data for sending to peer and QR display
                let claimPayload = ClaimData(
                    version: 1,
                    claimId: claimId,
                    secret: secret,
                    token: "USDC",
                    amount: amountValue
                )
                
                await MainActor.run {
                    claimData = claimPayload
                }
                
                // Wait for peer connection, then send data
                await MainActor.run {
                    // For now, simulate sending after 2 seconds
                    // In real implementation, this would wait for peer connection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        multipeerService.sendData(claimPayload)
                    }
                }
                
            } catch {
                await MainActor.run {
                    isCreatingClaim = false
                    errorMessage = "Failed to create claim: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    private func handleReceivedClaim(_ data: Data) {
        do {
            let claim = try JSONDecoder().decode(ClaimData.self, from: data)
            claimData = claim
        } catch {
            errorMessage = "Failed to decode claim data"
            showingError = true
        }
    }
}

// Models moved to Models.swift

#Preview {
    ClipContentView()
}
