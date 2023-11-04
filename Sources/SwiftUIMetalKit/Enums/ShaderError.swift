//
//  ShaderError.swift
//  
//
//  Created by Pirita Minkkinen on 10/25/23.
//

import Foundation

enum ShaderError: Error {
    case shaderNotFound(String)
    case shaderCompilationError(String)
    case otherError(String)
}
