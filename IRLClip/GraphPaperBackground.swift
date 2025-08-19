//
//  GraphPaperBackground.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI

struct GraphPaperBackground: View {
    var body: some View {
        ZStack {
            // Base color
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Graph paper grid
            Canvas { context, size in
                let gridSize: CGFloat = 20
                let lineWidth: CGFloat = 0.5
                
                // Vertical lines
                for x in stride(from: 0, through: size.width, by: gridSize) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(.gray.opacity(0.15)), lineWidth: lineWidth)
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: size.height, by: gridSize) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(.gray.opacity(0.15)), lineWidth: lineWidth)
                }
                
                // Thicker lines every 5th line
                let thickGridSize: CGFloat = gridSize * 5
                let thickLineWidth: CGFloat = 1.0
                
                // Thick vertical lines
                for x in stride(from: 0, through: size.width, by: thickGridSize) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(.gray.opacity(0.25)), lineWidth: thickLineWidth)
                }
                
                // Thick horizontal lines
                for y in stride(from: 0, through: size.height, by: thickGridSize) {
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(.gray.opacity(0.25)), lineWidth: thickLineWidth)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    GraphPaperBackground()
}
