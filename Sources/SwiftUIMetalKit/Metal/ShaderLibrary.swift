//
//  ShaderLibrary.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Metal

// Manages storage, retrieval, and usage of compiled shaders.
//todo: check why default shaders don't compile :)
internal class ShaderLibrary {
    static let shared = ShaderLibrary()
   
    private let metalLibrary: MTLLibrary
    let device: MTLDevice = DeviceManager.shared.device! //if its nil it already would have crashed
    
    private let shaderCompiler: ShaderCompiler  // Or whatever device you need
        
    enum ShaderState {
        case compiling
        case compiled(MTLFunction)
    }
    
    private var shaderCache: [String: ShaderState] = [:]
    
    // default shaders in the case user doesnt provide anything and is just trying out stuff
    static let defaultVertexShader: String = """
    vertex float4 defaultVertexShader(const device float4 *vertices [[ buffer(0) ]], uint vid [[ vertex_id ]]) { return vertices[vid];}
    """
    /*"""
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
    fragment float4 defaultFragmentShader(float2 textureCoordinate) {
    float4 blackToWhite = float4(textureCoordinate.x, textureCoordinate.x, textureCoordinate.x, 1.0);
    float4 blueToWhite = float4(0.0, 0.0, 1.0, 1.0) * (1.0 - textureCoordinate.y) + float4(1.0, 1.0, 1.0, 1.0) * textureCoordinate.y;
    return blackToWhite * blueToWhite;}
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
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragmentShader")
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertexShader")
    }
    

    private func compileFromStringAndStore(shaderSource: String, forKey key: String) {
        shaderCompiler.compileShaderAsync(shaderSource, key: key) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let shaderFunction):
                    self?.store(shader: shaderFunction, forKey: key)
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
    
    func store(shader: MTLFunction, forKey key: String) {
            shaderCache[key] = .compiled(shader)
        }
    /*
    func store(shader: MTLFunction, forKey key: String) {
        shaderCache[key] = shader
    }
    */
    func retrieveShader(forKey key: String) -> MTLFunction? {
        guard let shaderState = shaderCache[key] else {
            // Handle error: Shader doesn't exist
            fatalError("Shader for key \(key) does not exist.")
        }
        
        switch shaderState {
        case .compiling:
            // Handle waiting logic: wait until the shader is compiled
            let semaphore = DispatchSemaphore(value: 0)
            var shader: MTLFunction?
            DispatchQueue.global().async {
                while true {
                    if case let .compiled(compiledShader)? = self.shaderCache[key] {
                        shader = compiledShader
                        semaphore.signal()
                        break
                    }
                    // Optional: Sleep for a small amount of time to reduce active waiting
                    usleep(1000)  // 1ms
                }
            }
            semaphore.wait()
            return shader
            
        case .compiled(let compiledShader):
            // The shader is compiled, return it directly
            return compiledShader
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
            assert(false, "Failed to compile the provided shader. Please ensure your custom shader is correctly defined.")
            // Force unwrapping here because the default shaders are foundational to the package.
            // If they are absent, the entire functionality is compromised.
            return retrieveShader(forKey: "defaultFragmentShader")!
        }
    }

}

