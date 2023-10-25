//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI
import MetalKit

@available(iOS 14.0, *)
@available(macOS 11.0, *)
public struct MetalSwiftUIView: View {
    @ObservedObject var shaderViewModel = ShaderViewModel()
    let fragmentShaderName: String
    let vertexShaderName: String
    var shouldScaleByDimensions: Bool = true

    public init(fragmentShaderName: String?, vertexShaderName: String?, shouldScaleByDimensions: Bool = false) {
        self.shouldScaleByDimensions = shouldScaleByDimensions
        if let name = fragmentShaderName {
            self.fragmentShaderName = name
            //let shader = ShaderLibrary.shared.makeFunction(name: name)
            //ShaderLibrary.shared.store(shader: shader, forKey: name)
        } else {
            self.fragmentShaderName = "defaultFragmentShader"
        }
        if let name = vertexShaderName {
            self.vertexShaderName = name
            //let shader = ShaderLibrary.shared.makeFunction(name: name)
            //ShaderLibrary.shared.store(shader: shader, forKey: name)
        } else {
            self.vertexShaderName = "defaultVertexShader"
        }
    }
    
    
    public var body: some View {
        GeometryReader { geometry in
            switch shaderViewModel.viewState {
            case .placeholder:
                PlaceholderView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            case .metalView:
                #if os(macOS)
                    MetalNSViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
                #else
                    MetalUIViewRepresentable(viewSize: geometry.size, fragmentShaderName: fragmentShaderName,vertexShaderName: vertexShaderName, shouldScaleByDimensions: shouldScaleByDimensions)
                #endif
            }
        }
    }
}


//for more control over stopping and starting shader if thought it will be needed
/*
 Custom Bindings: Allow users to pass in bindings to your view, which can be updated based on shader lifecycle events. This is useful for two-way communication.

 Delegate Pattern: Although SwiftUI largely moves away from delegation in favor of more reactive patterns, you can still use a delegate approach if it fits better with your architecture.
 */
