//
//  ShaderView.swift
//
//  A SwiftUI view for displaying shaders using Metal.
//
//  Created by Pirita Minkkinen on 8/22/23.
//

//alternative name metalview wrapper


import SwiftUI
import MetalKit


/// `ShaderView` is a SwiftUI view that renders shaders using Metal. It supports custom vertex and fragment shaders.
/// It provides a fallback and placeholder view for different states of shader loading.
public struct ShaderView: View {
    @ObservedObject var shaderViewModel: ShaderViewModel
    let fragmentShaderName: String
    let vertexShaderName: String
    var usingDefaultShaders: Bool = true
    @State var shadersLoaded: Bool = false
    let fallbackView: AnyView
    let placeholderView: AnyView
    let shaderInput: any ShaderInputProtocol
    
    /// Initializes a new instance of `ShaderView`.
       /// - Parameters:
       ///   - fragmentShaderName: The name of the fragment shader. Uses a default shader if not provided.
       ///   - vertexShaderName: The name of the vertex shader. Uses a default shader if not provided.
       ///   - fallbackView: A view to show in case of an error.
       ///   - placeholderView: A view to display while shaders are loading.
       ///   - shaderInput: The input for the shader. If nil, a default instance is created.
    public init(fragmentShaderName: String? = nil, vertexShaderName: String? = nil, fallbackView: AnyView? = nil, placeholderView: AnyView? = nil, shaderInput: (any ShaderInputProtocol)? = nil) {
        self.fallbackView = fallbackView ?? AnyView(FallbackView())
        self.placeholderView = placeholderView ?? AnyView(PlaceholderView())
        self.shaderInput = shaderInput ?? ShaderInput()
        print(type(of: self.shaderInput))
        // Setup shader names and determine if default shaders are used.
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
        
        // Initialize the shader view model with the shader names and input.
        self.shaderViewModel = ShaderViewModel(vertexShaderName: self.vertexShaderName, fragmentShaderName: self.fragmentShaderName, shaderInput: self.shaderInput)
        
        // TODO: This is fine until adding loading and add real-time compilation for user shaders.
        if(!usingDefaultShaders){
            shaderViewModel.viewState = .metalView;
        }
        
    }
  
    
    
    public var body: some View {
        GeometryReader { geometry in
            if shadersLoaded { // Check if shaders have already been loaded
                // Display the Metal view since shaders have been loaded
#if os(macOS)
                
                MetalNSViewRepresentable(drawableSize: geometry.size, shaderViewModel: shaderViewModel)
#else
                MetalUIViewRepresentable(drawableSize: geometry.size, shaderViewModel: shaderViewModel)
#endif
            }
            else{
                switch shaderViewModel.viewState {
                case .placeholder:
                    placeholderView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .metalView:
                    
#if os(macOS)
                    MetalNSViewRepresentable(drawableSize: geometry.size, shaderViewModel: shaderViewModel)
                
#else
                    MetalUIViewRepresentable(drawableSize: geometry.size, shaderViewModel: shaderViewModel)
               
#endif
                    
                case .error:
                    fallbackView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }}
        }
        
        .onChange(of: shaderViewModel.viewState) { newState in
            if newState == .metalView {
                shadersLoaded = true
            }
        }
    }
}


