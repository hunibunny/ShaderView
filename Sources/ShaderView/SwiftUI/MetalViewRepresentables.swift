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
struct MetalNSViewRepresentable: NSViewRepresentable {
    typealias NSViewType = MetalRenderView
    
    @Binding var drawableSize: CGSize
    let shaderViewModel: ShaderViewModel
    
    /// Initializes a `MetalNSViewRepresentable` for macOS, setting up the necessary environment for Metal rendering.
    /// - Parameters:
    ///   - drawableSize: The size of the drawable area for Metal rendering.
    ///   - shaderViewModel: A `ShaderViewModel` instance containing shader names and input parameters.
    init(drawableSize: Binding<CGSize>, shaderViewModel: ShaderViewModel) {
        self._drawableSize = drawableSize
        self.shaderViewModel = shaderViewModel
    }
    
    /// Creates and configures a `MetalRenderView` for Metal rendering within a SwiftUI view hierarchy.
    /// - Returns: A configured instance of `MetalRenderView`.
    func makeNSView(context: Context) -> NSViewType{
        let metalRenderView = MetalRenderView(shaderViewModel: shaderViewModel)
        metalRenderView.delegate = metalRenderView
        metalRenderView.drawableSize = drawableSize
        return metalRenderView
    }
    
    /// Updates the `MetalRenderView` with the latest drawable size and triggers a redraw if necessary.
    /// - Parameters:
    ///   - nsView: The `MetalRenderView` to update.
    func updateNSView(_ nsView: MetalRenderView, context: Context) {
        nsView.updateSize(size: drawableSize)
    }
    
}

#else
/// `MetalUIViewRepresentable` is the iOS equivalent of `MetalNSViewRepresentable`.
struct MetalUIViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MetalRenderView
    
    @Binding var drawableSize: CGSize
    
    
    //let drawableSize: CGSize
    let shaderViewModel: ShaderViewModel
    
    
    /// Initializes a `MetalUIViewRepresentable` for iOS, setting up the necessary environment for Metal rendering.
    /// - Parameters:
    ///   - drawableSize: The size of the drawable area for Metal rendering.
    ///   - shaderViewModel: A `ShaderViewModel` instance containing shader names and input parameters.
    init(drawableSize: Binding<CGSize>, shaderViewModel: ShaderViewModel) {
        self._drawableSize = drawableSize
        self.shaderViewModel = shaderViewModel
    }
    
    
    /// Creates and configures a `MetalRenderView` for Metal rendering within a SwiftUI view hierarchy on iOS.
    /// - Returns: A configured instance of `MetalRenderView`.
    func makeUIView(context: Context) -> UIViewType {
        let metalRenderView = MetalRenderView(shaderViewModel: shaderViewModel)
        metalRenderView.delegate = metalRenderView
        metalRenderView.drawableSize = drawableSize
        return metalRenderView
    }
    
    /// Updates the `MetalRenderView` with the latest drawable size and triggers a redraw if necessary.
    /// - Parameters:
    ///   - uiView: The `MetalRenderView` to update.
    func updateUIView(_ uiView: MetalRenderView, context: Context) {
        uiView.updateSize(size: drawableSize)
        
    }
    
}
#endif
