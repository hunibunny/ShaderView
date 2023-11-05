//
//  MetalSwiftUIView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI
import MetalKit
import os


@available(iOS 14.0, *)
@available(macOS 11.0, *)
public struct MetalSwiftUIView: View {
    @ObservedObject var shaderViewModel: ShaderViewModel
    let fragmentShaderName: String
    let vertexShaderName: String
    let shaderInput: ShaderInput?
    var usingDefaultShaders: Bool = true
    @State var shadersLoaded: Bool = false

    public init(fragmentShaderName: String? = nil, vertexShaderName: String? = nil, shaderInput: ShaderInput? = nil) {
        if let name = fragmentShaderName {
            self.fragmentShaderName = name
            usingDefaultShaders = false
        } else {
            self.fragmentShaderName = "defaultFragmentShader"
        }

        if let name = vertexShaderName {
            self.vertexShaderName = name
            
        } else {
            self.vertexShaderName = "defaultVertexShader"
            usingDefaultShaders = true
        }
        self.shaderViewModel = ShaderViewModel(vertexShaderName: self.vertexShaderName, fragmentShaderName: self.fragmentShaderName)
        self.shaderInput = shaderInput
        if(!usingDefaultShaders){
            shaderViewModel.viewState = .metalView;
        }
    }
    
    
    public var body: some View {
        GeometryReader { geometry in
            if shadersLoaded { // Check if shaders have already been loaded
                    // Display the Metal view since shaders have been loaded
                    #if os(macOS)
                    MetalNSViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
                    #else
                    MetalUIViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
                    #endif
                }
            else{
                switch shaderViewModel.viewState {
                case .placeholder:
                    PlaceholderView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .metalView:
                    
#if os(macOS)
                    MetalNSViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
                    //.id(UUID())
#else
                    MetalUIViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName,vertexShaderName: vertexShaderName, shaderInput: shaderInput)
                    //.id(UUID())
#endif
                }
            }
        }
        .onChange(of: shaderViewModel.viewState) { newState in
                if newState == .metalView {
                    shadersLoaded = true
                    os_log("Switched to metalView.", type: .info)
                }
            }
        .frame(minWidth: 100, minHeight: 100) // provide a minimum size
        .background(Color.blue) // add a background color to visually debug
    }
    
}



