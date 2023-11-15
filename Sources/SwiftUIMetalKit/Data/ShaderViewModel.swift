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
    private var vertexShaderCompiled = false
    private var fragmentShaderCompiled = false
    private var transitionedToMetalView = false
    
    
    init(vertexShaderName: String, fragmentShaderName: String) {
        self.vertexShaderName = vertexShaderName
        self.fragmentShaderName = fragmentShaderName

        shaderSubscription = ShaderLibrary.shared.shaderStateSubject.sink { [weak self] in
            let (key, state) = $0
            self?.handleShaderStateUpdate(forKey: key, state: state)
        }

        shaderSubscription?.store(in: &cancellables)
        
        //TODO: is this good enough accuracy or should I add more precise for checking both individually
        if ShaderLibrary.shared.getDefaultShadersCompiled(){
            vertexShaderCompiled = true
            fragmentShaderCompiled = true
        }
    }

    private func handleShaderStateUpdate(forKey key: String, state: ShaderState) {
        switch state {
        case .compiled(_):
            if key == vertexShaderName {
                vertexShaderCompiled = true
            } else if key == fragmentShaderName {
                fragmentShaderCompiled = true
            }

            if vertexShaderCompiled && fragmentShaderCompiled {
                viewState = .metalView
            }
            
        case .error:
            viewState = .error
        default:
            break
        }
        
        if viewState == .error || (vertexShaderCompiled && fragmentShaderCompiled) {
            shaderSubscription?.cancel()
            shaderSubscription = nil
        }
    }

    deinit {
        // Cancel any subscribers when the view model is de-initialized to avoid memory leaks.
        cancellables.forEach { $0.cancel() }
    }
}
