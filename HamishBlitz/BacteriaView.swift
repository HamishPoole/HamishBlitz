//
//  BacteriaView.swift
//  HamishBlitz
//
//  Created by Hamish Poole on 8/1/2023.
//

import SwiftUI

struct BacteriaView: View {
    /**
     # Object representing the view of the underyling Bacteria data.
     To be layered by the zstack of GameBoard.
     */
    var bacteria: Bacteria
    var rotationAction: () -> Void
    
    var image: String {
        // Image displayed on the view.
        // Only three image choices, which are rotated.  Only major graphical assets of the game!
        switch bacteria.color {
        case .red:
            return "chevron.up.square.fill"
        case .green:
            return "chevron.up.circle.fill"
        default:
            return "chevron.up.circle"
        }
    }
    
    var body: some View {
        ZStack {
            Button(action: rotationAction) {
                Image(systemName: image)
                    .resizable()
                    .foregroundColor(bacteria.color)
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)
            
            Rectangle()
                .fill(bacteria.color)
                .frame(width: 3, height: 8)
                .offset(y: -20)
        }
        .rotationEffect(.degrees(bacteria.direction.rotation))
    }
}

struct BacteriaView_Previews: PreviewProvider {
    static var previews: some View {
        BacteriaView(bacteria: Bacteria(row: 0, col: 0)) {
        }
    }
}
