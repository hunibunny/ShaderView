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
    
    private var device: MTLDevice?
    
    private let shaderCompiler: ShaderCompiler?
    
    private var defaultShadersCompiled: Bool = false
    
    private var shaderCache: [String: ShaderState] = [:]
    let shaderStateSubject = PassthroughSubject<(name: String, state: ShaderState), Never>() // Subject to publish shader state changes.
    
    static let viewportStruct: String = """
        struct Viewport {
            float2 size;
        };
        """
    
    static let vertexShaderOutputStruct: String = """
        struct VertexOutput {
            float4 position [[position]];
            float2 screenCoord;
        };
        """
    
    static let shaderInputStruct: String = """
    struct ShaderInput {
        float time;
    };
    """
    
    
    static let commonShaderSource: String = vertexShaderOutputStruct + viewportStruct + shaderInputStruct
    //static let vertexShaderSource: String = viewportSizeStruct + vertexShaderOutputStruct
    //static let fragmentShaderSource: String = viewportSizeStruct + shaderInputStruct
    
    //default shaders <3
    static let defaultVertexShader: String = commonShaderSource + """
    vertex VertexOutput defaultVertexShader(uint vertexID [[vertex_id]],
                                               constant Viewport& viewport [[buffer(0)]]) {
        float2 positions[4] = {
            float2(-1.0, -1.0),
            float2(1.0, -1.0),
            float2(-1.0, 1.0),
            float2(1.0, 1.0)
        };
        
        VertexOutput out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        //out.screenCoord = positions[vertexID] * 0.5 * viewport.size;
        // Map NDC (-1 to 1 range) to framebuffer coordinates (0 to 1 range)
        out.screenCoord = (positions[vertexID] + 1.0) * 0.5;
        return out;
    }
    """
    
    
    static let defaultFragmentShader: String = commonShaderSource + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]],
                                               constant Viewport& viewport [[buffer(0)]],
                                                constant ShaderInput &shaderInput [[buffer(1)]]) {
        // Check which quadrant the pixel is in and color accordingly
        if (viewport.size.x > 0 && viewport.size.y > 0) {
            return float4(1, 1, 0, 1); // Yellow for top-right quadrant
        } else if (viewport.size.x < 0 && viewport.size.y > 0) {
            return float4(0, 1, 0, 1); // Green for top-left quadrant
        } else if (viewport.size.x < 0 && viewport.size.y < 0) {
            return float4(0, 0, 1, 1); // Blue for bottom-left quadrant
        } else {
            return float4(1, 0, 0, 1); // Red for bottom-right quadrant
        }
    }
    """
    
    
    private init() {
        self.device = DeviceManager.shared.device
                
        if DeviceManager.shared.isSuccessfullyInitialized {
                self.shaderCompiler = ShaderCompiler()
                if shaderCompiler == nil || !shaderCompiler!.isSuccessfullyInitialized {
                    performFallback()
                }
            } else {
                self.shaderCompiler = nil
                performFallback()
            }
    
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertexShader")
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragmentShader")
  
    }
    
    //TODO: reconsider this name lol
    private func performFallback(){
        shaderStateSubject.send((name: "error", state: .error))
    }

    
    //TODO: finnish this
    func areDefaultShadersCompiled() -> Bool {
            // Check if the default shaders are compiled and return the result.
            // This could be as simple as checking for the presence of certain keys in a dictionary.
        return true
    }
    
    
    private func compileFromStringAndStore(shaderSource: String, forKey key: String) {
        self.store(shader: .compiling, forKey: key)
        shaderCompiler!.compileShaderAsync(shaderSource, key: key) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let shaderFunction):
                    //os_log("Attempting to store shader with a key %@", log: OSLog.default, type: .debug, key)
                    self?.store(shader: .compiled(shaderFunction), forKey: key)
                    //os_log("Succesfully stored the shader with a key %@", log: OSLog.default, type: .debug, key)
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
        //os_log("Storing shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        shaderCache[key] = shader
        shaderStateSubject.send((name: key, state: shaderCache[key]!))
    }
    
    
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        //os_log("Retrieving shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        
        // First, check if the shader is in the cache.
        if let shaderState = shaderCache[key] {
            switch shaderState {
            case .compiled(let compiledShader):
                return compiledShader
            case .compiling:
                //TODO: should i wait for it here or not? not a current problem since this will never be called if shaders arent compiled, but in the future if i provide compilation during runtime this  will become a problem
                //os_log("Shader for key %{PUBLIC}@ is still compiling.", log: OSLog.default, type: .info, key)
                return nil
            case .error:
                // If there was an error, the shader is not available.
                os_log("Shader for key %{PUBLIC}@ had an error during compilation.", log: OSLog.default, type: .error, key)
                return nil
            }
        } else {
            // If the shader is not in the cache, attempt to create it using makeFunction.
            //os_log("Shader for key %{PUBLIC}@ not found in cache! Attempting to create it.", log: OSLog.default, type: .info, key)
            if let function = shaderCompiler!.makeFunction(name: key){
                shaderCache[key] = .compiled(function)
                return function
            } else {
                os_log("Failed to make shader function for key %{PUBLIC}@.", log: OSLog.default, type: .error, key)
                return nil
            }
        }
    }
    
    
    
    
    func makeFunction(name: String) -> MTLFunction {
        //os_log("Making function for name: %{PUBLIC}@", log: OSLog.default, type: .debug, name)
        if let shaderFunction = shaderCompiler!.makeFunction(name: name){
            return shaderFunction
        } else {
            assert(false, "Failed to load/retrieve the provided shade \(name). Please ensure your custom shader is correctly defined.")
            // Force unwrapping here because the default shaders are foundational to the package.
            // If they are absent, the entire functionality is compromised.
            return retrieveShader(forKey: "defaultFragmentShader")!
        }
    }
    
    private func fallbackGraphicsSetup(){
        
        
    }
    
    private func checkAndSetDefaultShadersCompiled(){
        if let vertexShaderState = shaderCache["defaultVertexShader"], let fragmentShaderState = shaderCache["defaultFragmentShader"] {
            switch (vertexShaderState, fragmentShaderState) {
            case (.compiled(_), .compiled(_)):
                defaultShadersCompiled = true
            default:
                defaultShadersCompiled = false
            }
        }
    }
    
    func getDefaultShadersCompiled()->Bool{
        if !defaultShadersCompiled{
            checkAndSetDefaultShadersCompiled()
        }
        return defaultShadersCompiled;
    }
    
    
}

