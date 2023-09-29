//
//  ShaderLibrary.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Metal


//this is only for me, not for others hehe
internal class ShaderLibrary {
    static let shared = ShaderLibrary()
    
    private var shaderCache: [String: MTLFunction] = [:]
    
    // default shaders in the case user doesnt provide anything and is just trying out stuff
    static let defaultVertexShader: String = """
    vertex float4 basic_vertex_function(const device float4 *vertices [[ buffer(0) ]], uint vid [[ vertex_id ]]) {
        return vertices[vid];
    }
    """
    static let defaultFragmentShader: String = """
    fragment float4 basic_fragment_function() {
        return float4(1.0, 1.0, 1.0, 1.0); // RGBA for white
    }
    """
    private init() {
        compileAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragment")
        compileAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertex")
    }
    
    private func compileAndStore(shaderSource: String, forKey key: String) {
           guard let device = MTLCreateSystemDefaultDevice(),
                 let library = try? device.makeLibrary(source: shaderSource, options: nil),
                 let shaderFunction = library.makeFunction(name: "basic_fragment_function") else {
               fatalError("Failed to compile and store shader for key \(key)")
        }
        shaderCache[key] = shaderFunction
    }
    
    func store(shader: MTLFunction, forKey key: String) {
        shaderCache[key] = shader
    }
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        return shaderCache[key]
    }
}

//ShaderLibrary.shared.store(shader: someShader, forKey: "basicVertex")
//let retrievedShader = ShaderLibrary.shared.retrieveShader(forKey: "basicVertex")


