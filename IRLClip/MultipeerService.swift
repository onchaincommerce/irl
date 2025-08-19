//
//  MultipeerService.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import MultipeerConnectivity
import Foundation

class MultipeerService: NSObject, ObservableObject {
    private let serviceType = "irl-bump-v1"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    @Published var isAdvertising = false
    @Published var isBrowsing = false
    @Published var connectedPeers: [MCPeerID] = []
    @Published var receivedData: Data?
    
    private var discoveryTimeout: Timer?
    private var sendTimeout: Timer?
    
    override init() {
        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func startAdvertising() {
        stopAdvertising()
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        isAdvertising = true
        
        // Set discovery timeout
        discoveryTimeout = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            self.handleDiscoveryTimeout()
        }
    }
    
    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isAdvertising = false
        discoveryTimeout?.invalidate()
        discoveryTimeout = nil
    }
    
    func startBrowsing() {
        stopBrowsing()
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        isBrowsing = true
        
        // Set discovery timeout
        discoveryTimeout = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            self.handleDiscoveryTimeout()
        }
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        isBrowsing = false
        discoveryTimeout?.invalidate()
        discoveryTimeout = nil
    }
    
    func sendData(_ claimData: ClaimData) {
        guard !connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(claimData)
            try session.send(data, toPeers: connectedPeers, with: .reliable)
            
            // Set send timeout
            sendTimeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                self.handleSendTimeout()
            }
        } catch {
            print("Error sending data: \(error)")
        }
    }
    
    private func handleDiscoveryTimeout() {
        print("Discovery timeout - showing QR fallback")
        // TODO: Show QR fallback UI
    }
    
    private func handleSendTimeout() {
        print("Send timeout")
        // TODO: Handle send timeout
    }
    
    private func tearDownSession() {
        session.disconnect()
        stopAdvertising()
        stopBrowsing()
        connectedPeers.removeAll()
    }
}

// MARK: - MCSessionDelegate
extension MultipeerService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Connected to \(peerID.displayName)")
                self.connectedPeers.append(peerID)
                // Stop discovery once connected
                self.stopAdvertising()
                self.stopBrowsing()
                
            case .connecting:
                print("Connecting to \(peerID.displayName)")
                
            case .notConnected:
                print("Not connected to \(peerID.displayName)")
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                
            @unknown default:
                print("Unknown state for \(peerID.displayName)")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            print("Received data from \(peerID.displayName)")
            self.receivedData = data
            
            // Tear down session after receiving data
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.tearDownSession()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used in this implementation
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used in this implementation
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used in this implementation
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        // Auto-accept first invitation
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer \(peerID.displayName)")
        // Auto-invite first found peer
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer \(peerID.displayName)")
    }
}
