//
//  ChessboardView.swift
//  ColorfulApp
//
//  Created by 秋星桥 on 2024/7/4.
//

import Foundation
import SwiftUI

struct ChessboardView: View {
    let gridSize: CGFloat = 32

    var body: some View {
        GeometryReader { geometry in
            let numberOfColumns = Int(geometry.size.width / gridSize)
            let numberOfRows = Int(geometry.size.height / gridSize)

            Canvas { context, _ in
                for row in 0 ..< numberOfRows + 1 {
                    for column in 0 ..< numberOfColumns + 1 {
                        let x = CGFloat(column) * gridSize
                        let y = CGFloat(row) * gridSize
                        let rect = CGRect(x: x, y: y, width: gridSize, height: gridSize)
                        context.fill(Path(rect), with: .color(.clear))
                        context.stroke(Path(rect), with: .color(.black), lineWidth: 0.5)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
