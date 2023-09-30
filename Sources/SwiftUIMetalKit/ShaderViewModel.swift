//
//  ShaderViewModel.swift
//  
//
//  Created by Pirita Minkkinen on 10/1/23.
//

import Foundation

class ShaderViewModel: ObservableObject {
    @Published var isRunning: Bool = false

    func startShader() {
        isRunning = true
    }

    func stopShader() {
        isRunning = false
    }
}
