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
    
    enum AppMode {
        case initial
        case sender
        case receiver
        case claiming
        case success
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image("irl_demon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("IRL")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Instant value transfer between iPhones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                // Main content based on mode
                switch mode {
                case .initial:
                    initialView
                case .sender:
                    senderView
                case .receiver:
                    receiverView
                case .claiming:
                    claimingView
                case .success:
                    successView
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Check if we were invoked with a claim URL (receiver mode)
            // For now, default to sender mode
            mode = .sender
        }
    }
    
    @ViewBuilder
    private var initialView: some View {
        VStack(spacing: 20) {
            Button("Send Money") {
                mode = .sender
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Receive Money") {
                mode = .receiver
                multipeerService.startBrowsing()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
    
    @ViewBuilder
    private var senderView: some View {
        VStack(spacing: 20) {
            Text("Send USDC")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Text("$")
                    .font(.title)
                TextField("0.00", text: $amount)
                    .font(.title)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
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
            .disabled(amount.isEmpty || Double(amount) == nil || isCreatingClaim)
            
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
    
    private func createBump() {
        guard let amountValue = Double(amount) else { return }
        
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
