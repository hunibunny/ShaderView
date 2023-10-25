//
//  ShaderError.swift
//  
//
//  Created by Pirita Minkkinen on 10/25/23.
//

import Foundation

enum ShaderError: Error {
    case shaderNotFound
    case shaderStillCompiling
    case shaderCompilationError
}
