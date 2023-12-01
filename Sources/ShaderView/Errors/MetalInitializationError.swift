//
//  MetalInitializationError.swift
//  
//
//  Created by Pirita Minkkinen on 11/7/23.
//

import Foundation

enum MetalInitializationError: Error {
    case noDevice
    case noCommandQueue
}
