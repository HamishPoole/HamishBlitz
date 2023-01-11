//
//  ContentView.swift
//  HamishBlitz
//
//  Created by Hamish Poole on 8/1/2023.
//

import SwiftUI

    struct ContentView: View {
    /**
     # Struct of the views required.
     
     Swift's built around Model-View-Controller.  ContentView is a simple struct containing all the views.
     */
    @StateObject private var board = GameBoard()
    
    var body: some View {
        VStack {
            // Vertical stack.  View with elements laid out vertically.
            HStack {
                // HStack, horizontal stack.  Horizontal view.
                Text("GREEN: \(board.greenScore)")
                    .padding(.horizontal)
                    .background(Capsule().fill(.green).opacity(board.currentPlayer == .green ? 1 : 0))
                
                Spacer()
                
                Text("HamishBlitz")
                
                Spacer()
                
                Text("RED: \(board.redScore)")
                    .padding(.horizontal)
                    .background(Capsule().fill(.red).opacity(board.currentPlayer == .red ? 1 : 0))
            }
            .font(.system(size: 36).weight(.black))
            
            ZStack {
                // Z-axis stack.  Multiple views are layered, as Photoshop layers.
                VStack {
                    ForEach(0..<11, id: \.self) { row in
                        HStack {
                            ForEach(0..<22, id: \.self) { col in
                                // For each element in a (magic numbers hard coded, not pass by reference) grid size.
                                // Instantiate a BacteriaView.  BacteriaView presumably contains clickable elements.
                                let bacteria = board.grid[row][col]
                                
                                BacteriaView(bacteria: bacteria) {
                                    board.rotate(bacteria: bacteria)
                                    
                                }
                            }
                        }
                    }
                }
                
                if let winner = board.winner {
                    VStack {
                        Text("\(winner) wins!")
                            .font(.largeTitle)
                        Button(action: board.reset) {
                            Text("Play Again")
                                .padding()
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(40)
                    .background(.black.opacity(0.85))
                    .cornerRadius(25)
                    .transition(.scale)
                }
            }
            .padding()
            .fixedSize()
            .preferredColorScheme(.dark)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
