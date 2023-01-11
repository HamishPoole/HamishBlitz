//
//  HamishBlitzApp.swift
//  HamishBlitz
//
//  Created by Hamish Poole on 8/1/2023.
//

import SwiftUI

@main
struct HamishBlitzApp: App {
    /**
    # Main Method
     Creates a group of windows and initialises ContentView object.
    
    */
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
