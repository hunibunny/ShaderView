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


internal class ShaderLibrary {
    static let shared = ShaderLibrary()
   
    
    private let metalLibrary: MTLLibrary
    let device: MTLDevice = DeviceManager.shared.device! //if its nil it already would have crashed
    
    private let shaderCompiler: ShaderCompiler
    
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
    vertex VertexOutput defaultVertexShader(uint vertexID [[vertex_id]],
                                           constant ViewportSize &viewport [[buffer(0)]]) {
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
    //changed to [[buffer(0)]] from [[buffer(1)]]
    /*
    static let defaultFragmentShader: String = commonShaderSource + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]]) {
        return float4(1.0, 0.0, 0.0, 1.0);  // solid red
    }
    
    """

     */
    static let defaultFragmentShader: String = commonShaderSource + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]], constant ViewportSize &viewport [[buffer(0)]]) {
        if (viewport.size > 0) {
            return float4(0, 1, 0, 1);
        }
        // Check which quadrant the pixel is in and color accordingly
        if (in.screenCoord.x > 0 && in.screenCoord.y > 0) {
            return float4(1, 1, 0, 1); // Yellow for top-right quadrant
        } else if (in.screenCoord.x < 0 && in.screenCoord.y > 0) {
            return float4(0, 1, 0, 1); // Green for top-left quadrant
        } else if (in.screenCoord.x < 0 && in.screenCoord.y < 0) {
            return float4(0, 0, 1, 1); // Blue for bottom-left quadrant
        } else {
            return float4(1, 0, 0, 1); // Red for bottom-right quadrant
        }
    }
    """
     /*
      fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]]) {
      
           float2 textureCoordinate = in.position.xy * 0.5 + 0.5;  // Convert [-1, 1] to [0, 1]
           float4 blackToWhite = float4(textureCoordinate.x, textureCoordinate.x, textureCoordinate.x, 1.0);
           float4 blueToWhite = float4(0.0, 0.0, 1.0, 1.0) * (1.0 - textureCoordinate.y) + float4(1.0, 1.0, 1.0, 1.0) * textureCoordinate.y;
           return blackToWhite * blueToWhite;
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
                        //TODO: fatalerror probably not appropriate here
                    }
                }
            }
        }
    }
    
    func store(shader: ShaderState, forKey key: String) {
        os_log("Storing shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        shaderCache[key] = shader
        shaderStateSubject.send((name: key, state: shaderCache[key]!))
    }

    
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        os_log("Retrieving shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        
        // First, check if the shader is in the cache.
        if let shaderState = shaderCache[key] {
            switch shaderState {
            case .compiled(let compiledShader):
                return compiledShader
            case .compiling:
                //TODO: should i wait for it here or not? not a current problem since this will never be called if shaders arent compiled, but in the future if i provide compilation during runtime this  will become a problem
                os_log("Shader for key %{PUBLIC}@ is still compiling.", log: OSLog.default, type: .info, key)
                return nil
            case .error:
                // If there was an error, the shader is not available.
                os_log("Shader for key %{PUBLIC}@ had an error during compilation.", log: OSLog.default, type: .error, key)
                return nil
            }
        } else {
            // If the shader is not in the cache, attempt to create it using makeFunction.
            os_log("Shader for key %{PUBLIC}@ not found in cache! Attempting to create it.", log: OSLog.default, type: .info, key)
            if let function = metalLibrary.makeFunction(name: key) {
                shaderCache[key] = .compiled(function)
                return function
            } else {
                os_log("Failed to make shader function for key %{PUBLIC}@.", log: OSLog.default, type: .error, key)
                return nil
            }
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

