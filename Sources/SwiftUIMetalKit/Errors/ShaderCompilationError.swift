//
// ShaderCompilationError.swift
//  
//
//  Created by Pirita Minkkinen on 10/15/23.
//

import Foundation

enum ShaderCompilationError: Error {
    
    case functionCreationFailed(String)
    // Add more error cases as needed
}

/*enum ShaderCompilationError: Error {
 case functionCreationFailed(String)
 case shaderRetrievalFailed(String)
 // Add more error cases as needed
 
 var errorDescription: String {
     switch self {
     case .functionCreationFailed(let message):
         return "Function creation failed: \(message)"
     case .shaderRetrievalFailed(let message):
         return "Shader retrieval failed: \(message)"
     }
 }
 
 // Additional logging or actions as per error case
 func logError() {
     os_log("%{PUBLIC}@", log: OSLog.default, type: .error, self.errorDescription)
     // Additional actions or logging as needed
 }
}
 
 do {
     // Try to retrieve a shader
     let shader = try retrieveShader(forKey: "myShaderKey")
 } catch let error as ShaderCompilationError {
     error.logError()
 }

*/
