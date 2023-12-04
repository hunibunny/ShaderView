//
//  MetalViewRepresentables.swift
//
//A SwiftUI representable for integrating Metal-based rendering in SwiftUI views.
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI


/// `MetalNSViewRepresentable` (macOS) or `MetalUIViewRepresentable` (iOS) are SwiftUI views that facilitate the rendering of Metal content.
/// They act as a bridge between `ShaderView` and `MetalRenderView`, handling the necessary setup and updates for Metal rendering.
///
/// - Note: These representables handle the basic displaying process but do not manage errors related to shader compilation,
///   Metal device initialization, or runtime issues. Users should handle these aspects separately.
#if os(macOS)
public struct MetalNSViewRepresentable: NSViewRepresentable {
    public typealias NSViewType = MetalRenderView
    
    let drawableSize: CGSize
    let shaderViewModel: ShaderViewModel
    
    /// Initializes a `MetalNSViewRepresentable` for macOS, setting up the necessary environment for Metal rendering.
    /// - Parameters:
    ///   - drawableSize: The size of the drawable area for Metal rendering.
    ///   - shaderViewModel: A `ShaderViewModel` instance containing shader names and input parameters.
    public init(drawableSize: CGSize, shaderViewModel: ShaderViewModel) {
        self.drawableSize = drawableSize
        self.shaderViewModel = shaderViewModel
    }
    
    /// Creates and configures a `MetalRenderView` for Metal rendering within a SwiftUI view hierarchy.
    /// - Returns: A configured instance of `MetalRenderView`.
    public func makeNSView(context: Context) -> NSViewType{
        let metalRenderView = MetalRenderView(shaderViewModel: shaderViewModel)
        metalRenderView.delegate = metalRenderView
        metalRenderView.drawableSize = drawableSize
        return metalRenderView
    }
    
    /// Updates the `MetalRenderView` with the latest drawable size and triggers a redraw if necessary.
    /// - Parameters:
    ///   - nsView: The `MetalRenderView` to update.
    public func updateNSView(_ nsView: MetalRenderView, context: Context) {
        nsView.frame.size = drawableSize
        nsView.drawableSize = drawableSize
        nsView.needsDisplay = true
    }
    
}

#else
/// `MetalUIViewRepresentable` is the iOS equivalent of `MetalNSViewRepresentable`.
public struct MetalUIViewRepresentable: UIViewRepresentable {
    let drawableSize: CGSize
    let fragmentShaderName: String
    let vertexShaderName: String
    public typealias UIViewType = MetalRenderView
    let shaderInput: ShaderInputProtocol
    
    /// Initializes a `MetalUIViewRepresentable` for iOS, setting up the necessary environment for Metal rendering.
    /// - Parameters:
    ///   - drawableSize: The size of the drawable area for Metal rendering.
    ///   - shaderViewModel: A `ShaderViewModel` instance containing shader names and input parameters.
    public init(drawableSize: CGSize, shaderViewModel: ShaderViewModel) {
        self.drawableSize = drawableSize
        self.shaderViewModel = shaderViewModel
    }
    
    
    /// Creates and configures a `MetalRenderView` for Metal rendering within a SwiftUI view hierarchy on iOS.
    /// - Returns: A configured instance of `MetalRenderView`.
    public func makeUIView(context: Context) -> UIViewType {
        let metalRenderView = MetalRenderView(fragmentShaderName: fragmentShaderName, vertexShaderName: vertexShaderName, shaderInput: shaderInput)
        metalRenderView.delegate = metalRenderView
        metalRenderView.drawableSize = drawableSize
        return metalRenderView
    }
    
    /// Updates the `MetalRenderView` with the latest drawable size and triggers a redraw if necessary.
    /// - Parameters:
    ///   - uiView: The `MetalRenderView` to update.
    public func updateUIView(_ uiView: MetalRenderView, context: Context) {
        uiView.frame.size = drawableSize
        uiView.drawableSize = drawableSize
        uiView.setNeedsDisplay()
    }
    
}
#endif
