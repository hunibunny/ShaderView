//
//  ShaderView.swift
//
//  A SwiftUI view for displaying shaders using Metal.
//
//  Created by Pirita Minkkinen on 8/22/23.
//


import SwiftUI
import MetalKit


/// `ShaderView` is a SwiftUI view that renders shaders using Metal. It supports custom vertex and fragment shaders.
/// It provides a fallback and placeholder view for different states of shader loading.
public struct ShaderView: View {
    @ObservedObject var shaderViewModel: ShaderViewModel
 
    @State var shadersLoaded: Bool = false
    var usingDefaultShaders: Bool = true
    
    let fallbackView: AnyView
    let placeholderView: AnyView
    
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
        
        if(shaderInput == nil){
            ShaderViewLogger.debug("ShaderInput nil, new instance will be created")
        }
        
        
        
        let usingDefaultShaders = fragmentShaderName == nil || vertexShaderName == nil

        // Setup shader names and determine if default shaders are used.
        let finalFragmentShaderName = fragmentShaderName ?? "defaultFragmentShader"
        let finalVertexShaderName = vertexShaderName ?? "defaultVertexShader"
               
       
        
        // Initialize the shader view model with the shader names and input.
        self.shaderViewModel = ShaderViewModel(vertexShaderName: finalVertexShaderName, fragmentShaderName: finalFragmentShaderName, shaderInput: shaderInput ?? ShaderInput(time: 0.0))

        // TODO: This is fine until adding loading and add real-time compilation for user shaders.
        if(!usingDefaultShaders){
            shaderViewModel.viewState = .metalView;
        }
        
    }
  
    
    public var body: some View {
        GeometryReader { geometry in
            
                contentView(for: shaderViewModel.viewState, size: geometry.size)
                .onChange(of: geometry.size) { newSize in
                                    print("GeometryReader size changed to: \(newSize)")
                                }
                       }
        .onChange(of: shaderViewModel.viewState) { newState in
            shadersLoaded = newState == .metalView
        }
    }
    

    private func contentView(for state: ViewState, size: CGSize) -> some View {
        switch state {
        case .metalView:
            return AnyView(MetalViewRepresentable(drawableSize: size, shaderViewModel: shaderViewModel))
        case .placeholder:
            return AnyView(placeholderView)
        case .error:
            return AnyView(fallbackView)
        }
    }
    
    

}


