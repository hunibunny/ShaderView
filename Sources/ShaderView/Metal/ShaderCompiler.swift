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
    private let queue = DispatchQueue(label: "com.shaderViewPackage.ShaderCompiler")
    
    init?() {
        guard let sharedDevice = DeviceManager.shared.device else {
            ShaderViewLogger.error("MTLDevice could not be obtained from DeviceManager.")
            return nil
        }
        self.device = sharedDevice
        
        guard let newLibrary = device.makeDefaultLibrary() else {
            ShaderViewLogger.error("Failed to create the default MTLLibrary.")
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
        ShaderViewLogger.debug("Going to start to compile a shader with key: \(key)")
        
        DispatchQueue.global().async {
            ShaderViewLogger.debug("Starting compilation for a shader with key: \(key)")
            
                // Synchronize access to the device
                var shaderLibrary: MTLLibrary?
                DispatchQueue.main.sync {
                    do {
                        let compileOptions = MTLCompileOptions()
                        compileOptions.fastMathEnabled = false
                        shaderLibrary = try self.device.makeLibrary(source: source, options: compileOptions)
                    } catch let error as NSError {
                        ShaderViewLogger.error("Error compiling Metal library: \(error)")
                        completion(.failure(.functionCreationFailed("Failed to create shader with key: \(key) due to error with creating library from string")))
                    }
                }
                
           
                guard let library = shaderLibrary, let shaderFunction = library.makeFunction(name: key) else {
                    ShaderViewLogger.error("Failed to create shader with key: \(key)")
                    completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                    return
                }
            ShaderViewLogger.debug("Successfully created a shader with key: \(key)")
                completion(.success(shaderFunction))
           
        }
    }
    
}


