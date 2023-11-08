//
//  ShaderLibraryInitializationError.swift
//  
//
//  Created by Pirita Minkkinen on 11/8/23.
//

import Foundation

enum ShaderLibraryInitializationError: Error{
    case deviceCreationFailed
    case shaderCompilerCreationFailed
}
