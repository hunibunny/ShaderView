//
//  ShaderCompiler.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal
import os.log

// Manages the compilation of shader source code into usable shaders.
class ShaderCompiler {
    //static let shared = ShaderCompiler(device: DeviceManager.shared.device)

    
    let device: MTLDevice = DeviceManager.shared.device!  //i should really remove the optionality lol
    let library: MTLLibrary
    
    init(library: MTLLibrary) {
        self.library = library
        
    }
    
    func compileShaderAsync(_ source: String, key: String, completion: @escaping (Result<MTLFunction, ShaderCompilationError>) -> Void) {
        
        // Print the entire shader source code
        print("Shader source code for key \(key):\n\(source)")
        
        print("compile started")
        
        DispatchQueue.global().async {
            os_log("Attempting to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            
            // Assuming you have access to the MTLDevice as 'device'
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


    
    /*
    func compileShaderAsync(_ source: String, key: String, completion: @escaping (Result<MTLFunction, ShaderCompilationError>) -> Void) {
        print("Shader source code for key \(key):\n\(source)")
        print("compile started")
        DispatchQueue.global().async {
            os_log("Attempting to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            guard let shaderFunction = self.library.makeFunction(source: source) else {
                os_log("Failed to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .error, key)
                completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                return
            }
            os_log("Successfully created a shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            completion(.success(shaderFunction))
        }

        DispatchQueue.global().async {
            guard let shaderFunction = self.library.makeFunction(name: key) else {
                completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                return
            }
            os_log("Successfully created a shader with key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            completion(.success(shaderFunction))
        }*/
    }

}


