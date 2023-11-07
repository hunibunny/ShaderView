//
//  ShaderCompiler.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal
import os.log


class ShaderCompiler {
    private let device: MTLDevice
    private let library: MTLLibrary
    
    init?() {
        guard let sharedDevice = DeviceManager.shared.device else {
            print("MTLDevice could not be obtained from DeviceManager.")
            return nil
        }
        self.device = sharedDevice
        
        guard let newLibrary = sharedDevice.makeDefaultLibrary() else {
            print("Failed to create the default MTLLibrary.")
            return nil
        }
        self.library = newLibrary
    }
    
    func compileShaderAsync(_ source: String, key: String, completion: @escaping (Result<MTLFunction, ShaderCompilationError>) -> Void) {
        
        // Print the entire shader source code
        print("Shader source code for key \(key):\n\(source)")
        
        print("compile started")
        
        DispatchQueue.global().async {
            os_log("Attempting to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            do {
                let shaderLibrary = try self.device.makeLibrary(source: source, options: nil)
                guard let shaderFunction = shaderLibrary.makeFunction(name: key) else {
                    os_log("Failed to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .error, key)
                    completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                    return
                }
                os_log("Successfully created a shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
                completion(.success(shaderFunction))
            } catch let error {
                os_log("Failed to create shader library for key: %{PUBLIC}@ due to error: %{PUBLIC}@", log: OSLog.default, type: .error, key, error.localizedDescription)
                completion(.failure(.functionCreationFailed("Failed to create shader library for key: \(key) due to error: \(error.localizedDescription)")))
            }
        }
    }
}


