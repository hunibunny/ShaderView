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
               Logger.error("MTLDevice could not be created.")
               initializationError = MetalInitializationError.noDevice
           }
           
           if let device = device {
               commandQueue = device.makeCommandQueue()
               if commandQueue == nil {
                   Logger.error("MTLCommandQueue could not be created.")
                   initializationError = MetalInitializationError.noCommandQueue
               }
           }
       }
    
    
    var isSuccessfullyInitialized: Bool {
        return device != nil && commandQueue != nil
    }
    
    
    // TODO: check if this Provides a safe way to access the command queue or is unnecessary
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

