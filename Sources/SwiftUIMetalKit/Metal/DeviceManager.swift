//
//  DeviceManager.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal

// The DeviceManager class is designed as a singleton to manage and provide shared access to MTLDevice and related objects
class DeviceManager {
    static let shared = DeviceManager()
    
    private(set) var initializationError: Error?
    private(set) var device: MTLDevice?
    private(set) var commandQueue: MTLCommandQueue?
    
    private init() {
        device = MTLCreateSystemDefaultDevice()
        if device == nil {
            initializationError = MetalInitializationError.noDevice
        }
        
        if let device = device {
            commandQueue = device.makeCommandQueue()
            if commandQueue == nil {
                initializationError = MetalInitializationError.noCommandQueue
            }
        }
    }
    
    func verifyInitialization() throws -> (device: MTLDevice, commandQueue: MTLCommandQueue) {
        if let error = initializationError {
            throw error
        }
        if let device = device, let commandQueue = commandQueue {
            return (device, commandQueue)
        } else {
            throw MetalInitializationError.noDevice // Or a more appropriate error
        }
        
    }
    
    // Provides a safe way to access the command queue
        func getCommandQueue() throws -> MTLCommandQueue {
            if let commandQueue = self.commandQueue {
                return commandQueue
            } else if let error = self.initializationError {
                throw error
            } else {
                throw MetalInitializationError.noCommandQueue
            }
        }
}

//let commandQueue = try DeviceManager.shared.getCommandQueue()

