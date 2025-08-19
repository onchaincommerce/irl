//
//  IRLClipApp.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI

@main
struct IRLClipApp: App {
    var body: some Scene {
        WindowGroup {
            ClipContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    // Handle App Clip invocation URL
                    if let url = userActivity.webpageURL {
                        handleAppClipURL(url)
                    }
                }
        }
    }
    
    private func handleAppClipURL(_ url: URL) {
        // Parse claim ID from URL like https://irl.app/claim/{claimId}
        let pathComponents = url.pathComponents
        if pathComponents.count >= 3 && pathComponents[1] == "claim" {
            let claimId = pathComponents[2]
            // TODO: Pass claimId to the view
            print("App Clip invoked with claim ID: \(claimId)")
        }
    }
}
