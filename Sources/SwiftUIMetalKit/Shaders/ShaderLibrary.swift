//
//  ShaderLibrary.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation

struct ShaderLibrary {

    // Static constant for the shader
    static let basicVertexFunction: String = """
    vertex float4 basic_vertex_function(const device float4 *vertices [[ buffer(0) ]], uint vid [[ vertex_id ]]) {
        return vertices[vid];
    }
    """

    // If needed, static methods to compute or retrieve other values
    static func getCustomShader(for feature: String) -> String {
        // Compute or retrieve the appropriate shader source based on the feature
        return "..." // Placeholder for the actual shader source
    }
}
