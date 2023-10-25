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
//consider moving fragmentshadername and vertexshadername here
    
    init() {
           shaderSubscription = ShaderLibrary.shared.shaderStateSubject.sink { [weak self] in
               let (key, state) = $0
               self?.handleShaderStateUpdate(forKey: key, state: state)
           }

           // Store the subscription to manage it later.
           shaderSubscription?.store(in: &cancellables)
       }

    private func handleShaderStateUpdate(forKey key: String, state: ShaderState) {
        // Handle the received state for the shader.
        switch state {
        case .compiled(_):
            // Do something with mtlFunction if needed.
            viewState = .metalView // Set the view state
            shaderSubscription?.cancel()  // Stop listening to further updates
            shaderSubscription = nil
        case .compiling:
            // Handle the compiling state if necessary.
            break
        case .error:
            // Handle error state if necessary.
            break
        }
    }

    deinit {
        // Cancel any subscribers when the view model is de-initialized to avoid memory leaks.
        cancellables.forEach { $0.cancel() }
    }
}
