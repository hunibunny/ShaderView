//
//  MetalElementProtocol.swift
//  
//
//  Created by Pirita Minkkinen on 8/22/23.
//



#if os(macOS)
import AppKit
typealias MetalCompatibleView = NSView
#else
import UIKit
typealias MetalCompatibleView = UIView
#endif

protocol MetalElementProtocol: MetalCompatibleView {}
    
