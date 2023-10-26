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


//typealias ShaderRetrievalCompletion = (MTLFunction?, Error?) -> Void


// Manages storage, retrieval, and usage of compiled shaders.
//todo: check why default shaders don't compile :)
internal class ShaderLibrary {
    static let shared = ShaderLibrary()
   
    
    private let metalLibrary: MTLLibrary
    let device: MTLDevice = DeviceManager.shared.device! //if its nil it already would have crashed
    
    private let shaderCompiler: ShaderCompiler  // Or whatever device you need
        
   
    
    private var shaderCache: [String: ShaderState] = [:]
    let shaderStateSubject = PassthroughSubject<(name: String, state: ShaderState), Never>() // Subject to publish shader state changes.
    
    static let commonShaderSource: String = """
    struct ViewportSize {
        float2 size;
    };
    struct VertexOutput {
        float4 position [[position]];
        float2 screenCoord;
    };
    """

    
    // default shaders in the case user doesnt provide anything and is just trying out stuff
    static let defaultVertexShader: String = commonShaderSource + """
    vertex VertexOutput defaultVertexShader(uint vertexID [[vertex_id]], constant ViewportSize &viewport [[buffer(1)]]) {
        float2 positions[4] = {
            float2(-1.0, -1.0),
            float2(1.0, -1.0),
            float2(-1.0, 1.0),
            float2(1.0, 1.0)
        };
        
        VertexOutput out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.screenCoord = positions[vertexID] * 0.5 * viewport.size;  // Convert from clip space [-1, 1] to screen space.
        return out;
    }
    """
    
    static let defaultFragmentShader: String = commonShaderSource + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]]) {
        float2 textureCoordinate = in.position.xy * 0.5 + 0.5;  // Convert [-1, 1] to [0, 1]
        float4 blackToWhite = float4(textureCoordinate.x, textureCoordinate.x, textureCoordinate.x, 1.0);
        float4 blueToWhite = float4(0.0, 0.0, 1.0, 1.0) * (1.0 - textureCoordinate.y) + float4(1.0, 1.0, 1.0, 1.0) * textureCoordinate.y;
        return blackToWhite * blueToWhite;
    }
    """

 
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

    
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        os_log("Retrieving shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        
        guard let shaderState = shaderCache[key] else {
            os_log("Shader for key %{PUBLIC}@ not found!", log: OSLog.default, type: .error, key)
            return nil
        }

        switch shaderState {
        case .compiled(let compiledShader):
            os_log("Retrieved shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
            return compiledShader
        case .compiling, .error:
            return nil
        }
    }


    
    func makeFunction(name: String) -> MTLFunction {
        os_log("Making function for name: %{PUBLIC}@", log: OSLog.default, type: .debug, name)
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

