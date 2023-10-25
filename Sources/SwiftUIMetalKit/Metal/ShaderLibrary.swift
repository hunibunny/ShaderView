//
//  ShaderLibrary.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Metal
import os.log
import Combine


typealias ShaderRetrievalCompletion = (MTLFunction?, Error?) -> Void


// Manages storage, retrieval, and usage of compiled shaders.
//todo: check why default shaders don't compile :)
internal class ShaderLibrary {
    static let shared = ShaderLibrary()
   
    
    private let metalLibrary: MTLLibrary
    let device: MTLDevice = DeviceManager.shared.device! //if its nil it already would have crashed
    
    private let shaderCompiler: ShaderCompiler  // Or whatever device you need
        
   
    
    private var shaderCache: [String: ShaderState] = [:]
    let shaderStateSubject = PassthroughSubject<(name: String, state: ShaderState), Never>() // Subject to publish shader state changes.
    
    // default shaders in the case user doesnt provide anything and is just trying out stuff
    static let defaultVertexShader: String = """
    vertex float4 defaultVertexShader(uint vertexID [[vertex_id]]) {
        float2 positions[4] = {
            float2(-1.0, -1.0),
            float2(1.0, -1.0),
            float2(-1.0, 1.0),
            float2(1.0, 1.0)
        };
        return float4(positions[vertexID], 0.0, 1.0);
    }
    """
    /*"""
     
     fragment float4 defaultVertexShader() {
         return float4(1.0, 1.0, 1.0, 1.0); // RGBA for white
     }
    vertex float4 defaultVertexShader(device float3 *vertices [[ buffer (0) ]], uint vertexID [[ vertex_id ]]){ return float4(vertices[vertexID], 1);}
    """
                                        
    
   */
    /*
    static let defaultFragmentShader: String = """
    fragment float4 defaultFragmentShader() {
        return float4(1.0, 1.0, 1.0, 1.0); // RGBA for white
    }
    """
     */
    
    static let defaultFragmentShader: String = """
    fragment float4 defaultFragmentShader(float2 textureCoordinate [[stage_in]]) {
        float4 blackToWhite = float4(textureCoordinate.x, textureCoordinate.x, textureCoordinate.x, 1.0);
        float4 blueToWhite = float4(0.0, 0.0, 1.0, 1.0) * (1.0 - textureCoordinate.y) + float4(1.0, 1.0, 1.0, 1.0) * textureCoordinate.y;
        return blackToWhite * blueToWhite;
    }
    """
   
  /*
   vertex float4 basic_vertex_shader (device float3 *vertices [[ buffer (0) ]],
                                      uint vertexID [[ vertex_id ]]){
        return float4(vertices[vertexID], 1);
   }
   */
 
    private init() {
        guard let library = device.makeDefaultLibrary() else {
                    fatalError("Failed to initialize Metal library")
        }
        self.metalLibrary = library
        self.shaderCompiler = ShaderCompiler(library: library)
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertexShader")
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragmentShader")
        
    }
    

    private func compileFromStringAndStore(shaderSource: String, forKey key: String) {
        self.store(shader: .compiling, forKey: key)
        shaderCompiler.compileShaderAsync(shaderSource, key: key) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let shaderFunction):
                    os_log("Attempting to store shader with a key %@", log: OSLog.default, type: .debug, key)
                    self?.store(shader: .compiled(shaderFunction), forKey: key)
                    os_log("Succesfully stored the shader with a key %@", log: OSLog.default, type: .debug, key)
                case .failure(let error):
                    switch error {
                    case .functionCreationFailed(let errorMessage):
                        fatalError("Failed to compile and store shader for key \(key): \(errorMessage)")
                        // Remember to replace `fatalError` with appropriate error handling for production 
                    }
                }
            }
        }
    }
    
    func store(shader: ShaderState, forKey key: String) {
        os_log("Storing shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        shaderCache[key] = shader
        shaderStateSubject.send((name: key, state: shaderCache[key]!))
        //shaderStateSubject.send((name: name, state: .compiled))
    }

    /*
     if /* shader already exists for the key */ {
         os_log("Overwriting shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
     }
     // Your storage logic
     os_log("Stored shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)

     */
    /*
    func store(shader: MTLFunction, forKey key: String) {
        shaderCache[key] = shader
    }
     
     func retrieveShader(forKey key: String) -> MTLFunction? {
    */
    
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        os_log("Retrieving shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        
        guard let shaderState = shaderCache[key] else {
            os_log("Shader for key %{PUBLIC}@ not found!", log: OSLog.default, type: .error, key)
            return nil
        }

        switch shaderState {
        case .compiled(let compiledShader):
            return compiledShader
        case .compiling, .error:
            return nil
        }
    }


    
    /*
    func retrieveShader(forKey key: String) -> MTLFunction? {
        return shaderCache[key]
    }*/
    
    func makeFunction(name: String) -> MTLFunction {
        if let shaderFunction = metalLibrary.makeFunction(name: name) {
            return shaderFunction
        } else {
            assert(false, "Failed to load/retrieve the provided shade \(name). Please ensure your custom shader is correctly defined.")
            // Force unwrapping here because the default shaders are foundational to the package.
            // If they are absent, the entire functionality is compromised.
            return retrieveShader(forKey: "defaultFragmentShader")!
        }
    }

}

