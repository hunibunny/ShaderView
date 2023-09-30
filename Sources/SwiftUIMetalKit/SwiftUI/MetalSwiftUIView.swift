//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI
import MetalKit

public struct MetalSwiftUIView: View {
    let fragmentShaderName: String
    let vertexShaderName: String
    var shouldScaleByDimensions: Bool = true

    public init(fragmentShaderName: String?, vertexShaderName: String?, shouldScaleByDimensions: Bool = false) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        if let name = fragmentShaderName {
            self.fragmentShaderName = name
            let shader = ShaderLibrary.shared.makeFunction(name: name)
            ShaderLibrary.shared.store(shader: shader, forKey: name)
        } else {
            self.fragmentShaderName = "defaultFragmentShader"
        }
        if let name = vertexShaderName {
            self.vertexShaderName = name
            let shader = ShaderLibrary.shared.makeFunction(name: name)
            ShaderLibrary.shared.store(shader: shader, forKey: name)
        } else {
            self.vertexShaderName = "defaultVertexShader"
        }
    }
    public var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
                MetalNSViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
            #else
                MetalUIViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName,vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
            #endif
        }
    }
}
