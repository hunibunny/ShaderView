//
//  MetalViewWrapper.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct MetalSwiftUIView: View {
    #if os(macOS)
    var body: some View {
        MetalNSViewRepresentable()
    }
    #else
    var body: some View {
        MetalUIViewRepresentable()
    }
    #endif
}

#if os(macOS)

struct MetalNSViewRepresentable: NSViewRepresentable {

    typealias NSViewType = MetalElement // If you have a macOS specific version, use it here

    // Implement required methods for NSViewRepresentable...
}

#else

struct MetalUIViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MetalElement

    // Implement required methods for UIViewRepresentable...
}

#endif

