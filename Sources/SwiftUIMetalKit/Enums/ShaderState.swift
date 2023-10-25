//
//  ShaderState.swift
//  
//
//  Created by Pirita Minkkinen on 10/25/23.
//

import Foundation
import Metal

enum ShaderState{
    case compiling
    case compiled(MTLFunction)
    case error
}
