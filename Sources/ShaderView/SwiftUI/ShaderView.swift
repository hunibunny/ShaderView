//
//  ShaderView.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI
import MetalKit
import os

///Displays shaders in SwiftUI
@available(iOS 14.0, *)
@available(macOS 11.0, *)
public struct ShaderView<Input: ShaderInputProtocol>: View {
    @ObservedObject var shaderViewModel: ShaderViewModel
    let fragmentShaderName: String
    let vertexShaderName: String
    let shaderInput: Input?
    var usingDefaultShaders: Bool = true
    @State var shadersLoaded: Bool = false
    let fallbackView: AnyView
    let placeholderView: AnyView
    
    public init(fragmentShaderName: String? = nil, vertexShaderName: String? = nil, fallbackView: AnyView? = nil, placeholderView: AnyView? = nil, shaderInput: Input? = nil) {
        self.fallbackView = fallbackView ?? AnyView(FallbackView())
        self.placeholderView = placeholderView ?? AnyView(PlaceholderView())
        
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
        
        if shaderInput == nil {
            Logger.debug("Default instance of type \(Input.self) will be created")
        }

        //TODO: remove this when improving loadings and adding real time compilation for users shaders
        if(!usingDefaultShaders){
            shaderViewModel.viewState = .metalView;
        }
        
    }
  
    
    
    public var body: some View {
        GeometryReader { geometry in
            if shadersLoaded { // Check if shaders have already been loaded
                // Display the Metal view since shaders have been loaded
#if os(macOS)
                
                MetalNSViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput ?? Input.init())
#else
                MetalUIViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput ?? Input.init())
#endif
            }
            else{
                switch shaderViewModel.viewState {
                case .placeholder:
                    placeholderView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .metalView:
                    
#if os(macOS)
                    MetalNSViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput ?? Input.init())
                    //.id(UUID())
#else
                    MetalUIViewRepresentable(drawableSize: geometry.size, fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput ?? Input.init())
                    //.id(UUID())
#endif
                    
                case .error:
                    fallbackView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }}
        }
        
        .onChange(of: shaderViewModel.viewState) { newState in
            if newState == .metalView {
                shadersLoaded = true
                //os_log("Switched to metalView.", type: .info)
            }
        }
    }
}


