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
        
    private var shaderCache: [String: MTLFunction] = [:]
    
    // default shaders in the case user doesnt provide anything and is just trying out stuff
    static let defaultVertexShader: String = """
    vertex float4 defaultVertexShader(const device float4 *vertices [[ buffer(0) ]], uint vid [[ vertex_id ]]) {
        return vertices[vid];
    }
    """
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
    
 
    private init() {
        /*
        guard let validDevice = MetalManager.shared.device else {
            fatalError("Metal is not supported on this device.")
        }
        self.device = validDevice*/
        guard let library = device.makeDefaultLibrary() else {
                    fatalError("Failed to initialize Metal library")
        }
        self.metalLibrary = library
        self.shaderCompiler = ShaderCompiler(library: library)
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragmentShader")
        compileFromStringAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertexShader")
    }
    
 
    /*
    private func compileAndStore(shaderSource: String, forKey key: String) {
        //this part should be moved to shadercompiler
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = try? device.makeLibrary(source: shaderSource, options: nil),
              let shaderFunction = library.makeFunction(name: key) else {
            fatalError("Failed to compile and store shader for key \(key)")
        }
        shaderCache[key] = shaderFunction
    }*/
    
    
    //asunch version
    private func compileFromStringAndStore(shaderSource: String, forKey key: String) {
            shaderCompiler.compileShaderAsync(shaderSource, key: key) { [weak self] (shaderFunction) in
                guard let shaderFunction = shaderFunction else {
                    fatalError("Failed to compile and store shader for key \(key)")
                }
                DispatchQueue.main.async {
                    self?.shaderCache[key] = shaderFunction
                }
            }
        }
    
    func store(shader: MTLFunction, forKey key: String) {
        shaderCache[key] = shader
    }
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        return shaderCache[key]
    }
    
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

//ShaderLibrary.shared.store(shader: someShader, forKey: "basicVertex")
//let retrievedShader = ShaderLibrary.shared.retrieveShader(forKey: "basicVertex")


/*
 class ShaderLibrary {
     static let shared = ShaderLibrary()
     let device: MTLDevice
     
     private init() {
         guard let validDevice = MetalManager.shared.device else {
             fatalError("Metal is not supported on this device.")
         }
         self.device = validDevice
         // Other setup code...
     }
     
     // Additional code...
 }

 */

/*
 class ThreadSafeShaderLibrary {
     static let shared = ThreadSafeShaderLibrary()
     
     private let accessQueue = DispatchQueue(label: "com.example.shaderlibrary.access")
     private var _shader: MTLFunction?
     
     var shader: MTLFunction? {
         get {
             return accessQueue.sync {
                 return _shader
             }
         }
         set {
             accessQueue.sync {
                 _shader = newValue
             }
         }
     }
     
     // Other code...
 }

 */
