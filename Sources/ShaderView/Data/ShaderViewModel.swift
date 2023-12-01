//
//  ShaderViewModel.swift
//  
//
//  Created by Pirita Minkkinen on 10/1/23.
//

import Combine


class ShaderViewModel: ObservableObject {
    @Published var viewState: ViewState = .placeholder
    private var cancellables: Set<AnyCancellable> = []
    private var shaderSubscription: AnyCancellable?
    
    var vertexShaderName: String
    var fragmentShaderName: String
    private var vertexShaderReady = false
    private var fragmentShaderReady = false
    private var transitionedToMetalView = false
    
    
    init(vertexShaderName: String, fragmentShaderName: String) {
        self.vertexShaderName = vertexShaderName
        self.fragmentShaderName = fragmentShaderName
        
        if(!ShaderLibrary.shared.metalEnabled){
            viewState = .error
        }
        else{
            shaderSubscription = ShaderLibrary.shared.shaderStateSubject.sink { [weak self] in
                let (key, state) = $0
                self?.handleShaderStateUpdate(forKey: key, state: state)
            }
            
        
            if(vertexShaderName != "defaultVertexShader"){
                vertexShaderReady = true
            }
            else{
                if(ShaderLibrary.shared.isShaderCompiled(name: vertexShaderName)){
                    vertexShaderReady = true
                }
                    
            }
            
            
            if(fragmentShaderName != "defaultFragmentShader"){
                fragmentShaderReady = true
            }
            else{
                if(ShaderLibrary.shared.isShaderCompiled(name: fragmentShaderName)){
                    fragmentShaderReady = true
                }
                    
            }
            
            
            if vertexShaderReady, fragmentShaderReady{
                viewState = .metalView
                transitionedToMetalView = true
            }
            else{
                //only observe changes if some of them are needed
                shaderSubscription?.store(in: &cancellables)
            }
        }
    }

    private func handleShaderStateUpdate(forKey key: String, state: ShaderState) {
        switch state {
        case .compiled(_):
            if key == vertexShaderName {
                vertexShaderReady = true
            } else if key == fragmentShaderName {
                fragmentShaderReady = true
            }

            
            if vertexShaderReady && fragmentShaderReady {
                viewState = .metalView
            }
            
        case .error:
            Logger.error("Error compiling shader: \(key)")
            viewState = .error
        default:
            break
        }
        
        if viewState == .error || (vertexShaderReady && fragmentShaderReady) {
            shaderSubscription?.cancel()
            shaderSubscription = nil
        }
    }

    deinit {
        // Cancel any subscribers when the view model is de-initialized to avoid memory leaks.
        cancellables.forEach { $0.cancel() }
    }
}