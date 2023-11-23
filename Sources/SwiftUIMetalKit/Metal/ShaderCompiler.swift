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
    
    func compileShaderAsync(_ source: String, key: String, completion: @escaping (Result<MTLFunction, ShaderCompilationError>) -> Void) {
        
        // Print the entire shader source code
        //print("Shader source code for key \(key):\n\(source)")
        
        //print("compile started")
        
        DispatchQueue.global().async {
            Logger.debug(("Starting compilation for a shader with key: \(key)"));
            do {
                let shaderLibrary = try self.device.makeLibrary(source: source, options: nil)
                //TODO: no need to create new one, make sure when changing that asyncronus stuff wont make it to be a problem. Creating new library every compile will be problem if .metal files are long and there are many and/or if users will be compiling shaders during runtime
                //Use Efficient Synchronization: Implement lightweight synchronization (like NSLock or DispatchSemaphore) around access to the MTLLibrary. This will ensure thread safety without a significant performance hit.
                guard let shaderFunction = shaderLibrary.makeFunction(name: key) else {
                    //os_log("Failed to create shader with key: %{PUBLIC}@", log: OSLog.default, type: .error, key)
                    Logger.error("Failed to create shader with key:\(key)")
                    completion(.failure(.functionCreationFailed("Failed to create shader function with key: \(key)")))
                    return
                }
                Logger.debug(("Successfully created a shader with key: \(key)"));
                completion(.success(shaderFunction))
            } catch let error {
                Logger.error("Failed to create shader library for key: \(key) due to error : \(error.localizedDescription)")
                //os_log("Failed to create shader library for key: %{PUBLIC}@ due to error: %{PUBLIC}@", log: OSLog.default, type: .error, key, error.localizedDescription)
                completion(.failure(.functionCreationFailed("Failed to create shader library for key: \(key) due to error: \(error.localizedDescription)")))
            }
        }
    }
    
    func makeFunction(name: String) -> MTLFunction?{
        return library.makeFunction(name: name)
    }
}


