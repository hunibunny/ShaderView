//
//  ShaderCompiler.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal

// Manages the compilation of shader source code into usable shaders.
class ShaderCompiler {
    //static let shared = ShaderCompiler(device: DeviceManager.shared.device)

    
    let device: MTLDevice
    
    private init(device: MTLDevice?) {
        guard let validDevice = device else {
            fatalError("Metal is not supported on this device.")
        }
        self.device = validDevice
        // Other setup code...
    }
    
    // Additional code...
}


