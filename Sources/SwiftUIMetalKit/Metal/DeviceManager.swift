//
//  DeviceManager.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal

//TODO: check if device should be optional or not since i kinda really need it always :)
class DeviceManager {
    static let shared = DeviceManager()
    let device: MTLDevice?
    let commandQueue: MTLCommandQueue?

    private init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device!.makeCommandQueue()//the device is there, if its not there rip, i need to put better error message here
        assert(self.commandQueue != nil, "Failed to create a command queue. Ensure device is properly initialized and available.")
    }
    
}
