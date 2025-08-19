//
//  OTPDigitField.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI

struct OTPDigitField: View {
    @Binding var digit: String
    let isActive: Bool
    
    var body: some View {
        TextField("", text: $digit)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? .blue.opacity(0.1) : .gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? .blue : .gray.opacity(0.3), lineWidth: isActive ? 2 : 1)
                    )
            )
            .onTapGesture {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
    }
}

#Preview {
    OTPDigitField(digit: .constant("1"), isActive: true)
        .padding()
}
