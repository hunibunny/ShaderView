//
//  ShaderStoreError.swift
//  
//
//  Created by Pirita Minkkinen on 10/15/23.
//

import Foundation

//template for later use if i have need for this error
enum ShaderStoreError: Error {
    case shaderAlreadyExists(String)
    // ... other error cases ...
}

/*
 enum ShaderStoreError: Error {
     case shaderAlreadyExists(String)
     // ... other error cases ...
 }

 func store(shader: MTLFunction, forKey key: String) -> Result<Void, ShaderStoreError> {
     if /* shader already exists for the key */ {
         os_log("Attempted to overwrite shader for key: %{PUBLIC}@", log: OSLog.default, type: .error, key)
         return .failure(.shaderAlreadyExists(key))
     }
     // Your storage logic
     os_log("Stored shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
     return .success(())
 }
 In the above snippet, instead of directly logging or crashing, we return a Result type that can be checked by the caller, giving them control over how to handle the error condition.

 Application Development: Within a particular app, if a situation should never occur and does indicate a programming error, using assertions or fatal errors during development to catch these issues early is a common practice.
 */
