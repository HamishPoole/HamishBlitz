//
//  GameBoard.swift
//  HamishBlitz
//
//  Created by Hamish Poole on 8/1/2023.
//

import SwiftUI

class GameBoard: ObservableObject {
    let rowCount = 11
    let columnCount = 22
    
    @Published var grid = [[Bacteria]]()
    
    @Published var currentPlayer = Color.green
    @Published var greenScore = 1
    @Published var redScore = 1
    
    @Published var winner: String? = nil
    
    var bacteriaBeingInfected = 0
    
    init() {
        reset()
    }
    
    func reset() {
        winner = nil
        currentPlayer = .green
        redScore = 1
        greenScore = 1
        grid.removeAll()
        
        Bacteria(row: 0, col: 0).direction = .north
        Bacteria(row: 0, col: 1).direction = .east
        Bacteria(row: 1, col: 0).direction = .south
        
        for row in 0..<rowCount {
            var newRow = [Bacteria]()
            // [] Array in Swift.  Type goes in the Array.  () initialises.
            for col in 0..<columnCount {
                let bacteria = Bacteria(row: row, col: col)
                if row <= rowCount / 2 {
                    bacteria.direction = Bacteria.Direction.allCases.randomElement()!
                } else {
                    if let counterpart = getBacteria(atRow: rowCount - 1 - row, col: columnCount - 1 - col) {
                        // if let is a Walrus operator (presumably).  If getBacteria is true, assign & evaluate block.
                        bacteria.direction = counterpart.direction.opposite
                    }
                }
                newRow.append(bacteria)
            }
            
            grid.append(newRow)
        }
        
        grid[0][0].color = .green
        grid[rowCount - 1][columnCount - 1].color = .red
    }
    
    func getBacteria(atRow row: Int, col: Int) -> Bacteria? {
        guard row >= 0 else { return nil }
        guard row < grid.count else { return nil }
        guard col >= 0 else { return nil }
        guard col < grid[0].count else { return nil }
        return grid[row][col]
    }

    func checkGridBounds(atRow row: Int, col: Int) -> Bool {
        let condition = (row >= 0 && row < grid.count && col >= 0 && col < grid[0].count)
        // guard BoardRows.contains(row) else {return nil} is much better than my approach.
        return condition
    }
    
    func infect(from: Bacteria) {
        objectWillChange.send()
        
        var bacteriaToInfect = [Bacteria?]()
        
        // direct infection
        switch from.direction {
        case .north:
            if checkGridBounds(atRow: from.row - 1, col: from.col) { bacteriaToInfect.append(grid[from.row - 1][from.col]) }
        case .south:
            bacteriaToInfect.append(getBacteria(atRow: from.row + 1, col: from.col))
        case .east:
            bacteriaToInfect.append(getBacteria(atRow: from.row, col: from.col + 1))
        case .west:
            bacteriaToInfect.append(getBacteria(atRow: from.row - 1, col: from.col - 1))
        }
        
        // indirect infection from above.
        if let indirect = getBacteria(atRow: from.row - 1, col: from.col) {
            if indirect.direction == .south {
                bacteriaToInfect.append(indirect)
            }
        }
        
        if let indirect = getBacteria(atRow: from.row + 1, col: from.col) {
            if indirect.direction == .north {
                bacteriaToInfect.append(indirect)
            }
        }
        
        if let indirect = getBacteria(atRow: from.row, col: from.col - 1) {
            if indirect.direction == .east {
                bacteriaToInfect.append(indirect)
            }
        }
        
        if let indirect = getBacteria(atRow: from.row, col: from.col + 1) {
            if indirect.direction == .west {
                bacteriaToInfect.append(indirect)
            }
        }
        
        for case let bacteria? in bacteriaToInfect {
            if bacteria.color != from.color {
                bacteria.color = from.color
                bacteriaBeingInfected += 1
                
                Task { @MainActor in
                    // Main actor is used for UI updates.  Avoid updating the main view with background threads (race conditions, and likely other stuff(?))
                    try await Task.sleep(nanoseconds: 50_000_000)
                    bacteriaBeingInfected -= 1
                    infect(from: bacteria)
                }
            }
        }
        
        updateScores()
    }
    
    func rotate(bacteria: Bacteria) {
        guard bacteria.color == currentPlayer else { return }
        guard bacteriaBeingInfected == 0 else { return }
        guard winner == nil else { return }
        
        objectWillChange.send()
        
        bacteria.direction = bacteria.direction.next
        
        infect(from: bacteria)
    }
    
    func changePlayer() {
        if currentPlayer == .green {
            currentPlayer = .red
        } else {
            currentPlayer = .green
        }
    }
    
    func updateScores() {
        var newRedScore = 0
        var newGreenScore = 0
        
        for row in grid {
            for bacteria in row {
                if bacteria.color == .red {
                    newRedScore += 1
                } else if bacteria.color == .green {
                    newGreenScore += 1
                }
            }
        }
        
        redScore = newRedScore
        greenScore = newGreenScore
        
        if bacteriaBeingInfected == 0 {
            withAnimation(.spring()) {
                if redScore == 0 {
                    // green wins!
                    winner = "Green"
                } else if greenScore == 0 {
                    // red wins!
                    winner = "Red"
                } else {
                    changePlayer()
                }
                
            }
        }
    }
}
