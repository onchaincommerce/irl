//
//  ScaleButtonStyle.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onTapGesture {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
    }
}

#Preview {
    Button("Test Button") {
        print("Tapped!")
    }
    .buttonStyle(ScaleButtonStyle())
    .padding()
}
