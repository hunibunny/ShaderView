//
//  MetalConfigurable+Default.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import MetalKit



extension MetalConfigurable where Self: MTKView {
    mutating func defaultInit() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        self.device = device
        self.commandQueue = device.makeCommandQueue()
        // ... rest of the method remains the same ...
    }
}
