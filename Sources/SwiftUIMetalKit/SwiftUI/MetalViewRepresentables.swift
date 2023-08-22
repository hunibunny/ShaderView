//
//  MetalViewRepresentables.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import SwiftUI


#if os(macOS)
struct MetalNSViewRepresentable: NSViewRepresentable {
    typealias NSViewType = MetalElement
        
    func makeNSView(context: Context) -> NSViewType {
        // Create and return an instance of MetalElement (or configure one as needed)
        let metalElement = MetalElement()
        metalElement.commonInit()
        return metalElement
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        // Update the MetalElement view with any required data or state
        // For this example, we're leaving it empty as there might be no updates necessary.
    }
}

#else
struct MetalUIViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MetalElement
    // Implement required methods for UIViewRepresentable...
}
#endif
