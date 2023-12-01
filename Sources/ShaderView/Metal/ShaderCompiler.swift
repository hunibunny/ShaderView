//
//  ShaderCompiler.swift
//  
//
//  Created by Pirita Minkkinen on 10/8/23.
//

import Foundation
import Metal


class ShaderCompiler {
    private let device: MTLDevice
    private let library: MTLLibrary  //this is the library used to access shaders from .metal files
    private let queue = DispatchQueue(label: "com.yourapp.ShaderCompiler")
    
    init?() {
        guard let sharedDevice = DeviceManager.shared.device else {
            Logger.error("MTLDevice could not be obtained from DeviceManager.")
            return nil
        }
        self.device = sharedDevice
        
        guard let newLibrary = device.makeDefaultLibrary() else {
            Logger.error("Failed to create the default MTLLibrary.")
            return nil
        }
        self.library = newLibrary
    }
    
    var isSuccessfullyInitialized: Bool {
        // Perform any additional checks if necessary
        return true
    }
    

    func makeFunction(name: String) -> MTLFunction?{
        return library.makeFunction(name: name)
    }
    
    func compileShaderAsync(_ source: String, key: String, completion: @escaping (Result<MTLFunction, ShaderCompilationError>) -> Void) {
        Logger.debug("Going to start to compile a shader with key: \(key)")
        
        DispatchQueue.global().async {
            Logger.debug("Starting compilation for a shader with key: \(key)")
            
                // Synchronize access to the device
                var shaderLibrary: MTLLibrary?
                DispatchQueue.main.sync {
                    do {
                        let compileOptions = MTLCompileOptions()
                        compileOptions.fastMathEnabled = false
                        shaderLibrary = try self.device.makeLibrary(source: source, options: compileOptions)
                    } catch {
                        //Logger.error("Failed to create shader with key: \(key) due to error with creating library from string")
                        completion(.failure(.functionCreationFailed("Failed to create shader with key: \(key) due to error with creating library from string")))
                    }
                }
                
           
                guard let library = shaderLibrary, let shaderFunction = library.makeFunction(name: key) else {
                    Logger.error("Failed to create shader with key: \(key)")
                    completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                    return
                }
                Logger.debug("Successfully created a shader with key: \(key)")
                completion(.success(shaderFunction))
           
        }
    }
    
}


