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
//consider moving fragmentshadername and vertexshadername here completely, now they r saved in both
    
    init(vertexShaderName: String, fragmentShaderName: String) {
        self.vertexShaderName = vertexShaderName
        self.fragmentShaderName = fragmentShaderName

        shaderSubscription = ShaderLibrary.shared.shaderStateSubject.sink { [weak self] in
            let (key, state) = $0
            self?.handleShaderStateUpdate(forKey: key, state: state)
        }

        // Store the subscription to manage it later.
        shaderSubscription?.store(in: &cancellables)
    }

    private func handleShaderStateUpdate(forKey key: String, state: ShaderState) {
        // Check which shader has been compiled and update the status accordingly.
        if key == vertexShaderName, case .compiled(_) = state {
            vertexShaderCompiled = true
        } else if key == fragmentShaderName, case .compiled(_) = state {
            fragmentShaderCompiled = true
        }

        // If both shaders are compiled, update the view state.
        if vertexShaderCompiled && fragmentShaderCompiled {
            viewState = .metalView
            transitionedToMetalView = true
            shaderSubscription?.cancel()  // Stop listening to further updates
            shaderSubscription = nil
        }
    }

    deinit {
        // Cancel any subscribers when the view model is de-initialized to avoid memory leaks.
        cancellables.forEach { $0.cancel() }
    }
}
