//
//  MetalElementProtocol.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//

import AppKit



#if os(macOS)
typealias MetalCompatibleView = NSView
#else
typealias MetalCompatibleView = UIView
#endif

protocol MetalElementProtocol: MetalCompatibleView, MetalConfigurable {}
