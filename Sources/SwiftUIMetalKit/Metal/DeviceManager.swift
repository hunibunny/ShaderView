//
//  DeviceManager.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal

class DeviceManager {
    static let shared = DeviceManager()
    let device: MTLDevice?

    private init() {
        device = MTLCreateSystemDefaultDevice()
        // Additional setup code...
    }
    
    // Other utility functions related to Metal could go here...
}
