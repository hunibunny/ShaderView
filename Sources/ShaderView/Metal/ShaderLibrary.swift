//
//  ShaderLibrary.swift
//  
//
//  Created by Pirita Minkkinen on 9/26/23.
//

import Foundation
import Metal
import os.log
import Combine


//TODO: consider saving the default shadernames in here so 1 source of truth staus and no harrd coded names to be confusing me if i decide to change them. They r needed in more than 1 place now
internal class ShaderLibrary {
    static let shared = ShaderLibrary()
    
    private var device: MTLDevice?
    
    private let shaderCompiler: ShaderCompiler?
    
    //TODO: check if i need this or no, probabyl if i enable runtime compiling for users
    var metalEnabled = true
    
    private var shaderCache: [String: ShaderState] = [:]
    let shaderStateSubject = PassthroughSubject<(name: String, state: ShaderState), Never>() // Subject to publish shader state changes.
    
    static let viewportStruct: String = """
        struct Viewport {
            float2 size;
        };
        """
    
    static let vertexShaderOutputStruct: String = """
        struct VertexOutput {
            float4 position [[position]];
            float2 screenCoord;
        };
        """
    
    static let shaderInputStruct: String = """
    struct ShaderInput {
        float time;
    };
    """
    
    
    static let commonShaderSource: String = vertexShaderOutputStruct + viewportStruct + shaderInputStruct
    //static let vertexShaderSource: String = viewportSizeStruct + vertexShaderOutputStruct
    //static let fragmentShaderSource: String = viewportSizeStruct + shaderInputStruct
    
    //default shaders <3
    static let defaultVertexShader: String = commonShaderSource + """
    vertex VertexOutput defaultVertexShader(uint vertexID [[vertex_id]],
                                               constant Viewport& viewport [[buffer(0)]]) {
        float2 positions[4] = {
            float2(-1.0, -1.0),
            float2(1.0, -1.0),
            float2(-1.0, 1.0),
            float2(1.0, 1.0)
        };
        
        VertexOutput out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        //out.screenCoord = positions[vertexID] * 0.5 * viewport.size;
        // Map NDC (-1 to 1 range) to framebuffer coordinates (0 to 1 range)
        out.screenCoord = (positions[vertexID] + 1.0) * 0.5;
        return out;
    }
    """
    
    
    static let defaultFragmentShader: String = commonShaderSource + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]],
                                               constant Viewport& viewport [[buffer(0)]],
                                                constant ShaderInput &shaderInput [[buffer(1)]]) {
        constant float pi = 3.14159265358979323846;
    
         
            float3 col = float3(0.0);
    
              
            
            //col = graphicItem2Layer(in.screenCoord, col, shaderInput.time, viewport.size); //spinning transparent shapes
            float2 p = in.screenCoord
            float3 col = col
            float time = shaderInput.time
            float2 resolution = viewport.size
            p *= 0.9;
                
            p.x += 0.5;
            p.y += time * 0.2;
            p.y += 0.5;
                
            float2 id = floor(p);
            float2 gr = fract(p) - 0.5;
                
            float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
            gr.y += sin(n * 50.0) * 0.2;
            gr *= clamp(n * 1.0, 0.6, 1.0);
                
            p = gr
            float d = 10.0;
            for (int i = 0; i < 3; i++) {
            p = abs(p) - 0.01;
            p *= float2x2(cos((45.0 + (30.0 * time))) * (pi / 180.0), -sin((45.0 + (30.0 * time))) * (pi / 180.0)), sin((45.0 + (30.0 * time))) * (pi / 180.0)), cos((45.0 + (30.0 * time)))
        
            p.y += 0.05;
            p *= 1.6;
                        
            float2 prevP = p;
    
            p.y += 0.2;
            p.x = abs(p.x);
            p.x -= 0.22;
            p *= float2x2(cos(30.0 * (pi / 180.0)), -sin(30.0 * (pi / 180.0)), sin(30.0 * (pi / 180.0)), cos(30.0 * (pi / 180.0)));
            
            d = length(p) - 0.4;
            d = max(-(length(p - float2(0.15, 0.0)) - 0.31), d);
    
            p = prevP;
            p.y -= 0.4;
            float d2 = length(p) - 0.4;
            d2 = max(-(length(p - float2(0.0, 0.15)) - 0.31), d2);
            d = min(d, d2);
    
            p = prevP;
            p.y -= 0.05;
            d2 = abs(length(p) - 0.35) - 0.05;
            d = abs(min(d, d2)) - 0.01;
            }
                    
                    col = mix(col, float3(0.4), smoothstep(0.0001, 0.0, d));
                    
    
    
            //col = lineGraphicsLayer(in.screenCoord, col, shaderInput.time, viewport.size); //background
                float2 p = in.screenCoord
                float3 col = col
                float time = shaderInput.time
                float2 resolution = viewport.size
                        p.x = abs(p.x);
                        p.y += time * 0.08;
                        p *= 4.0;
                        
                        float2 id = floor(p);
                        float2 gr = fract(p) - 0.5;
    
                        float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
                        gr *= float2x2(cos((90.0 * step(0.5, n)) * (pi / 180.0), -sin((90.0 * step(0.5, n)) * (pi / 180.0)), sin((90.0 * step(0.5, n)) * (pi / 180.0)), cos((90.0 * step(0.5, n)) * (pi / 180.0));
                      
                                    
    
                        float lineWidth = 0.008;
                        float3 lineColor = float3(0.8);
                        gr *= float2x2(cos(45 * (pi / 180.0)), -sin(45 * (pi / 180.0)), sin(45 * (pi / 180.0)), cos(45 * (pi / 180.0)));
                
                
                        gr.x = abs(gr.x) - 0.707;
                        
                        
                        gr *= float2x2(cos((20.0 * time * -1.0) * (pi / 180.0), -sin((20.0 * time * -1.0) * (pi / 180.0)), sin((20.0 * time * -1.0) * (pi / 180.0)), cos((20.0 * time * -1.0) * (pi / 180.0)));
                    
                        float d = abs(abs(length(gr) - 0.5) - 0.14) - lineWidth;
                            
                        gr = length(gr) * cos(fmod(atan2(gr.y, gr.x) + 6.28 / (2.0 * 8.0), 6.28 / ((2.0 * 8.0) * 0.5)) + (2.0 - 1.0) * 6.28 / (2.0 * 8.0));
                        gr -= 0.007;
                        gr *= float2x2(cos( 45.0 * (pi / 180.0)), -sin( 45.0 * (pi / 180.0)), sin( 45.0 * (pi / 180.0)), cos( 45.0 * (pi / 180.0)));
                        float d2 = max(abs(gr).x - 0.02, abs(gr).y - 1.0);
                            
                        d = max(-d2, d);
                            
                        
                        col = mix(col, lineColor, smoothstep(0.0001, -0.01, d));
                        
                        d = abs(abs(length(gr) - 0.5) - 0.09) - lineWidth;
                        col = mix(col, lineColor, smoothstep(0.0001, -0.01, d));
    
                        
                        
                            gr *= float2x2(cos((20.0 * time * 1.0) * (pi / 180.0), -sin((20.0 * time * 1.0) * (pi / 180.0)), sin((20.0 * time * 1.0) * (pi / 180.0)), cos((20.0 * time * 1.0) * (pi / 180.0)));
                    
                            float d = abs(abs(length(gr) - 0.5) - 0.3) - lineWidth;
                            
                            gr = length(gr) * cos(fmod(atan2(gr.y, gr.x) + 6.28 / (2.0 * 8.0), 6.28 / ((2.0 * 8.0) * 0.5)) + (2.0 - 1.0) * 6.28 / (2.0 * 8.0));
                            gr -= 0.007;
                            gr *= float2x2(cos( 45.0 * (pi / 180.0)), -sin( 45.0 * (pi / 180.0)), sin( 45.0 * (pi / 180.0)), cos( 45.0 * (pi / 180.0)));
                            float d2 = max(abs(gr).x - 0.02, abs(gr).y - 1.0);
                            
                            d = max(-d2, d);
                      
                        col = mix(col, lineColor, smoothstep(0.0001, -0.01, d));
    
                        d = abs(abs(length(gr) - 0.5) - 0.19) - lineWidth;
                        col = mix(col, lineColor, smoothstep(0.0001, -0.01, d));
    
    
            //col = lineGraphicsLayer2(in.screenCoord, col, shaderInput.time, viewport.size); //+ on the background
                float2 p = in.screenCoord
                float3 col = col
                float time = shaderInput.time
                float2 resolution = viewport.size
                p.y += time * 0.08;
                p *= 4.0;
                p -= 0.5;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
    
                float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
    
                float lineWidth = 0.008;
                float3 lineColor = float3(0.8);
    
                
               
                    gr *= float2x2(cos((20.0 * time * 1.0) * (pi / 180.0), -sin((20.0 * time * 1.0) * (pi / 180.0)), sin((20.0 * time * 1.0) * (pi / 180.0)), cos((20.0 * time * 1.0) * (pi / 180.0)));
            
                    float d = abs(abs(length(gr) - 0.5) - 0.35) - lineWidth;
                    
                    gr = length(gr) * cos(fmod(atan2(gr.y, gr.x) + 6.28 / (1.5 * 8.0), 6.28 / ((1.5 * 8.0) * 0.5)) + (1.5 - 1.0) * 6.28 / (1.5 * 8.0));
                    gr -= 0.007;
                    gr *= float2x2(cos( 45.0 * (pi / 180.0)), -sin( 45.0 * (pi / 180.0)), sin( 45.0 * (pi / 180.0)), cos( 45.0 * (pi / 180.0)));
                    float d3 = max(abs(gr).x - 0.02, abs(gr).y - 1.0);
                    
                    d = max(-d3, d) * step(0.5, n);
                 
                
                    
                           
                                gr *= float2x2(cos((20.0 * time * 1.0) * (pi / 180.0), -sin((20.0 * time * 1.0) * (pi / 180.0)), sin((20.0 * time * 1.0) * (pi / 180.0)), cos((20.0 * time * 1.0) * (pi / 180.0)));
                        
                                float d2 = abs(abs(length(gr) - 0.5) - 0.35) - lineWidth;
                                
                                gr = length(gr) * cos(fmod(atan2(gr.y, gr.x) + 6.28 / (1.5 * 8.0), 6.28 / ((1.5 * 8.0) * 0.5)) + (1.5 - 1.0) * 6.28 / (1.5 * 8.0));
                                gr -= 0.007;
                                gr *= float2x2(cos( 45.0 * (pi / 180.0)), -sin( 45.0 * (pi / 180.0)), sin( 45.0 * (pi / 180.0)), cos( 45.0 * (pi / 180.0)));
                                float d3 = max(abs(gr).x - 0.02, abs(gr).y - 1.0);
                                
                                d2 = max(-d3, d) * step(0.5, n);
                             
                            
                d = min(d, d2);
                float d5 = max(abs(gr).x - 0.008, abs(gr).y - 0.08);
                float d4 = max(abs(gr).x - 0.08, abs(gr).y - 0.008);
                d2 = min(d5, d4) * (1.0 - step(0.5, n);
                d = min(d, d2);
                col = mix(col, lineColor, smoothstep(0.0001, -0.01, d));
    
    
            //col = graphicItem0Layer(in.screenCoord, col, shaderInput.time, viewport.size); //triple putkula
            float2 p = in.screenCoord
            float3 col = col
            float time = shaderInput.time
            float2 resolution = viewport.size
            p.x = abs(p.x);
            p.y += time * 0.1;
            p *= 2.5;
            float2 id = floor(p);
            float2 gr = fract(p) - 0.5;
                
            float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
            gr.x += sin(n * 2.0) * 0.25;
            gr.y += sin(n * 2.0) * 0.3 + step(0.9, n);
            gr *= clamp(n * 1.5, 0.85, 1.5);
                        
            float d = length(gr - float2(0.0, 0.12)) - 0.06;
            float d2 = max(abs(gr).x - 0.025, abs(gr).y - 0.1);
            d = min(d, d2);
            d2 = length(gr - float2(0.0, -0.098)) - 0.0256;
            d = abs(min(d, d2)) - 0.007;
                                    
            d2 = length(gr - float2(0.0, 0.12)) - 0.02;
            d = min(d, d2);
                                    
            d2 = length(gr - float2(0.0, 0.24)) - 0.015;
            d = min(d, d2);
                                        
            d2 = abs(length(gr - float2(0.0, 0.24)) - 0.03) - 0.002;
            d = min(d, d2);
                                        
            col = mix(col, float3(0.8), smoothstep(0.0001, 0.0, d));
            p.x = abs(p.x) - 0.12;
            p.y -= 0.1;
            float d = length(gr - float2(0.0, 0.12)) - 0.06;
            float d2 = max(abs(gr).x - 0.025, abs(gr).y - 0.1);
            d = min(d, d2);
            d2 = length(gr - float2(0.0, -0.098)) - 0.0256;
            d = abs(min(d, d2)) - 0.007;
                            
            d2 = length(gr - float2(0.0, 0.12)) - 0.02;
            d = min(d, d2);
                                        
            d2 = length(gr - float2(0.0, 0.24)) - 0.015;
            d = min(d, d2);
                                    
            d2 = abs(length(gr - float2(0.0, 0.24)) - 0.03) - 0.002;
            d = min(d, d2);
                                        
            col = mix(col, float3(0.8), smoothstep(0.0001, 0.0, d));
                
        
    
    
           // col = graphicItem0Layer2(in.screenCoord, col, shaderInput.time, viewport.size); //single putkula
                    float2 p = in.screenCoord
                    float3 col = col
                    float time = shaderInput.time
                    float2 resolution = viewport.size
                p.x = abs(p.x) - 0.12;
                p.y += time * 0.12;
                p *= 2.0;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
                gr.x += sin(n * 2.0) * 0.25;
                gr.y += sin(n * 2.0) * 0.3 + step(0.9, n);
                gr *= clamp(n * 1.5, 0.6, 1.5);
                float d = length(gr - float2(0.0, 0.12)) - 0.06;
                float d2 = max(abs(gr).x - 0.025, abs(gr).y - 0.1);
                d = min(d, d2);
                d2 = length(gr - float2(0.0, -0.098)) - 0.0256;
                d = abs(min(d, d2)) - 0.007;
                            
                d2 = length(gr - float2(0.0, 0.12)) - 0.02;
                d = min(d, d2);
                            
                d2 = length(gr - float2(0.0, 0.24)) - 0.015;
                d = min(d, d2);
                            
                d2 = abs(length(gr - float2(0.0, 0.24)) - 0.03) - 0.002;
                d = min(d, d2);
                            
                col = mix(col, float3(0.8), smoothstep(0.0001, 0.0, d));
    
            //col = graphicItem1Layer(in.screenCoord, col, shaderInput.time, viewport.size); //transparent non spinning
                float2 p = in.screenCoord
                float3 col = col
                float time = shaderInput.time
                float2 resolution = viewport.size
    
                p.x = abs(p.x) - 0.3;
                p.y += time * 0.15;
                p.y += 0.2;
                p *= 2.1;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = fract(sin(dot(id, float2(12.9898, 78.233))) * 43758.5453123);
                gr.x += sin(n * 10.0) * 0.1;
                gr.y += sin(n * 10.0) * 0.1 + step(0.9, n);
                gr *= float2x2(cos(n * 2.0), -sin(n * 2.0), sin(n * 2.0), cos(n * 2.0));
                gr *= clamp(n * 2.5, 0.85, 2.5);
                p = gr
                float2 prevP = p;
                float animate = 0.0
                p *= float2x2(cos((-30.0 * time) * (pi / 180.0) * animate), -sin((-30.0 * time) * (pi / 180.0) * animate), sin((-30.0 * time) * (pi / 180.0) * animate), cos((-30.0 * time) * (pi / 180.0) * animate));
                float size = 0.1;
                float d = max(abs(p).x - size - 0.02, abs(p).y - 0.1);
                p.x = abs(p.x) - size;
                p.y = abs(p.y) - size * 0.35;
                float a = (-120.0) * (pi / 180.0);
                d = max(-dot(p, float2(cos(a), sin(a))), d);
                d = abs(d) - 0.003;
                p.y = abs(p.y) - 0.19;
                p *= float2x2(cos((-30.0 * time) * (pi / 180.0) * animate), -sin((-30.0 * time) * (pi / 180.0) * animate), sin((-30.0 * time) * (pi / 180.0) * animate), cos((-30.0 * time) * (pi / 180.0) * animate));
                float size = 0.1;
                float d = max(abs(p).x - size - 0.02, abs(p).y - 0.1);
                p.x = abs(p.x) - size;
                p.y = abs(p.y) - size * 0.35;
                float a = (-120.0) * (pi / 180.0);
                d2 = max(-dot(p, float2(cos(a), sin(a))), d2);
                d2 = abs(d) - 0.003;
                d = min(d, d2);
                p = prevP;
                p.x = abs(p.x) - 0.16;
                p.y = abs(p.y) - 0.09;
                p *= float2x2(cos((-30.0 * time) * (pi / 180.0) * animate), -sin((-30.0 * time) * (pi / 180.0) * animate), sin((-30.0 * time) * (pi / 180.0) * animate), cos((-30.0 * time) * (pi / 180.0) * animate));
                float size = 0.1;
                float d = max(abs(p).x - size - 0.02, abs(p).y - 0.1);
                p.x = abs(p.x) - size;
                p.y = abs(p.y) - size * 0.35;
                float a = (-120.0) * (pi / 180.0);
                d2 = max(-dot(p, float2(cos(a), sin(a))), d2);
                d2 = abs(d) - 0.003;
                d = min(d, d2);
                col = mix(col, float3(0.7), smoothstep(0.0001, 0.0, d));
    
    
               
               return float4(col, 1.0);
        
    
    
    }
    """
    
    
    private init() {
        self.device = DeviceManager.shared.device
        
        if DeviceManager.shared.isSuccessfullyInitialized {
            self.shaderCompiler = ShaderCompiler()
            if shaderCompiler == nil {
                performFallback()
            }else{
                compileFromStringAndStore(shaderSource: ShaderLibrary.defaultVertexShader, forKey: "defaultVertexShader")
                compileFromStringAndStore(shaderSource: ShaderLibrary.defaultFragmentShader, forKey: "defaultFragmentShader")
            }
        } else {
            self.shaderCompiler = nil
            performFallback()
        }
    }
    
    //TODO: reconsider this name lol
    private func performFallback(){
        shaderStateSubject.send((name: "error", state: .error))
        metalEnabled = false
    }
    
    
    private func compileFromStringAndStore(shaderSource: String, forKey key: String) {
        self.store(shader: .compiling, forKey: key)
        shaderCompiler!.compileShaderAsync(shaderSource, key: key) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let shaderFunction):
                    Logger.debug("Attempting to store shader with a key: \(key)")
                    self?.store(shader: .compiled(shaderFunction), forKey: key)
                    Logger.debug("Succesfully stored shader with a key: \(key)")
                case .failure(let error):
                    switch error {
                    case .functionCreationFailed(let errorMessage):
                        //fatalError("Failed to compile and store shader for key \(key): \(errorMessage)")
                        Logger.error("Failed to compile and store shader for key \(key): \(errorMessage)")
                        //self?.fallbackGraphicsSetup()
                        self?.performFallback()
                    }
                }
            }
        }
    }
    
    private func store(shader: ShaderState, forKey key: String) {
        //os_log("Storing shader for key: %{PUBLIC}@", log: OSLog.default, type: .debug, key)
        Logger.debug("Storing shader for key: \(key)")
        shaderCache[key] = shader
        shaderStateSubject.send((name: key, state: shaderCache[key]!))
    }
    
    
    
    func retrieveShader(forKey key: String) -> MTLFunction? {
        Logger.debug("Retrieving shader for key: \(key)")
        // First, check if the shader is in the cache.
        if let shaderState = shaderCache[key] {
            switch shaderState {
            case .compiled(let compiledShader):
                return compiledShader
            case .compiling:
                //TODO: should i wait for it here or not? not a current problem since this will never be called if shaders arent compiled, but in the future if i provide compilation during runtime this  will become a problem
                //os_log("Shader for key %{PUBLIC}@ is still compiling.", log: OSLog.default, type: .info, key)
                return nil
            case .error:
                //TODO: consider fallbackbehavior
                // If there was an error, the shader is not available.
                Logger.error("Shader for key \(key) had an error during compilation.")
                //os_log("Shader for key %{PUBLIC}@ had an error during compilation.", log: OSLog.default, type: .error, key)
                return nil
            }
        } else {
            // If the shader is not in the cache, attempt to create it using makeFunction.
            //os_log("Shader for key %{PUBLIC}@ not found in cache! Attempting to create it.", log: OSLog.default, type: .info, key)
            if let function = shaderCompiler!.makeFunction(name: key){
                shaderCache[key] = .compiled(function)
                return function
            } else {
                os_log("Failed to make shader function for key %{PUBLIC}@.", log: OSLog.default, type: .error, key)
                return nil
            }
        }
    }
    
    
    private func makeFunction(name: String) -> MTLFunction {
        //os_log("Making function for name: %{PUBLIC}@", log: OSLog.default, type: .debug, name)
        Logger.debug("Making function for name: \(name)")
        if let shaderFunction = shaderCompiler!.makeFunction(name: name){
            return shaderFunction
        } else {
            assert(false, "Failed to load/retrieve the provided shade \(name). Please ensure your custom shader is correctly defined.")
            // Force unwrapping here because the default shaders are foundational to the package.
            // If they are absent, the entire functionality is compromised.
            return retrieveShader(forKey: "defaultFragmentShader")!
        }
    }
    
    func isShaderCompiled(name: String) -> Bool {
        guard let shaderState = shaderCache[name] else {
            //TODO: consider raising error. What would be more reasonable here?
            return false
        }
        if shaderState == .compiling {
            // If the shader is currently compiling, return false
            return false
        }
        
        return true
    }
    
    
}

