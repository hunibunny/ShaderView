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
    
    static let functions: String = """
            constant float pi = 3.14159265358979323846;

            metal::float2x2 Rot(float a) {
                return metal::float2x2(metal::cos(a), -metal::sin(a), metal::sin(a), metal::cos(a));
            }

            float B(float2 p, float2 s) {
                return metal::max(abs(p).x - s.x, abs(p).y - s.y);
            }

            float DF(float2 a, float b) {
                return metal::length(a) * metal::cos(fmod(atan2(a.y, a.x) + 6.28 / (b * 8.0), 6.28 / ((b * 8.0) * 0.5)) + (b - 1.0) * 6.28 / (b * 8.0));
            }

            // Convert degrees to radians
            float radians(float degrees) {
                return degrees * (pi / 180.0);
            }


            float random(float2 p) {
                return fract(metal::sin(metal::dot(p, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float3 graphicItem0(float2 p, float3 col, float2 resolution) {
                float d = metal::length(p - float2(0.0, 0.12)) - 0.06;
                float d2 = B(p, float2(0.025, 0.1));
                d = metal::min(d, d2);
                d2 = metal::length(p - float2(0.0, -0.098)) - 0.0256;
                d = abs(metal::min(d, d2)) - 0.007;
                
                d2 = metal::length(p - float2(0.0, 0.12)) - 0.02;
                d = metal::min(d, d2);
                
                d2 = metal::length(p - float2(0.0, 0.24)) - 0.015;
                d = metal::min(d, d2);
                
                d2 = abs(metal::length(p - float2(0.0, 0.24)) - 0.03) - 0.002;
                d = metal::min(d, d2);
                
                col = metal::mix(col, float3(0.8), metal::smoothstep(0.0001, 0.0, d));
                
                
                return col;
            }

            float3 graphicItem0Group(float2 p, float3 col, float2 resolution) {
                col = graphicItem0(p, col, resolution);
                p.x = abs(p.x) - 0.12;
                p.y -= 0.1;
                col = graphicItem0(p, col, resolution);
                return col;
            }

            float3 graphicItem0Layer(float2 p, float3 col, float time, float2 resolution) {
                p.x = abs(p.x);
                p.y += time * 0.1;
                p *= 2.5;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = random(id);
                gr.x += metal::sin(n * 2.0) * 0.25;
                gr.y += metal::sin(n * 2.0) * 0.3 + step(0.9, n);
                gr *= metal::clamp(n * 1.5, 0.85, 1.5);
                col = graphicItem0Group(gr, col, resolution);
                
                return col;
            }

            float hexagon(float2 p, float animate, float iTime) {
                p *= Rot(radians(-30.0 * iTime) * animate);
                float size = 0.1;
                float d = B(p, float2(size - 0.02, 0.1));
                p.x = abs(p.x) - size;
                p.y = abs(p.y) - size * 0.35;
                float a = radians(-120.0);
                d = metal::max(-metal::dot(p, float2(metal::cos(a), metal::sin(a))), d);
                return abs(d) - 0.003;
            }

            float3 graphicItem1(float2 p, float3 col, float time, float2 resolution) {
                float2 prevP = p;
                float d = hexagon(p, 0.0, time);
                p.y = abs(p.y) - 0.19;
                float d2 = hexagon(p, 0.0, time);
                d = metal::min(d, d2);
                p = prevP;
                p.x = abs(p.x) - 0.16;
                p.y = abs(p.y) - 0.09;
                d2 = hexagon(p, 1.0, time);
                d = metal::min(d, d2);
                col = metal::mix(col, float3(0.7), metal::smoothstep(0.0001, 0.0, d));

                
                return col;
            }

            float3 graphicItem2(float2 p, float3 col, float time, float2 resolution) {
                float d = 10.0;
                for (int i = 0; i < 3; i++) {
                    p = abs(p) - 0.01;
                    p *= Rot(radians(45.0 + (30.0 * time)));
                    p.y += 0.05;
                    p *= 1.6;
                    
                    float2 prevP = p;

                    p.y += 0.2;
                    p.x = abs(p.x);
                    p.x -= 0.22;
                    p *= Rot(radians(30.0));
                    d = metal::length(p) - 0.4;
                    d = metal::max(-(metal::length(p - float2(0.15, 0.0)) - 0.31), d);

                    p = prevP;
                    p.y -= 0.4;
                    float d2 = metal::length(p) - 0.4;
                    d2 = metal::max(-(metal::length(p - float2(0.0, 0.15)) - 0.31), d2);
                    d = metal::min(d, d2);

                    p = prevP;
                    p.y -= 0.05;
                    d2 = abs(metal::length(p) - 0.35) - 0.05;
                    d = abs(metal::min(d, d2)) - 0.01;
                }
                
                col = metal::mix(col, float3(0.4), metal::smoothstep(0.0001, 0.0, d));
                
                return col;
            }

            float3 graphicItem2Layer(float2 p, float3 col, float time, float2 resolution) {
                p *= 0.9;
                
                p.x += 0.5;
                p.y += time * 0.2;
                p.y += 0.5;
                
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = random(id);
                gr.y += metal::sin(n * 50.0) * 0.2;
                gr *= metal::clamp(n * 1.0, 0.6, 1.0);
                col = graphicItem2(gr, col, time, resolution);
                
                return col;
            }

            float circleAnimation(float2 p, float size, float lineWidth, float dir, float b, float time) {
                p *= Rot(radians(20.0 * time * dir));
                float d = abs(abs(metal::length(p) - 0.5) - size) - lineWidth;
                
                p = DF(p, b);
                p -= 0.007;
                p *= Rot(radians(45.0));
                float d2 = B(p, float2(0.02, 1.0));
                
                d = metal::max(-d2, d);
                return d;
            }

            float graphicItem3(float2 p) {
                float d = B(p, float2(0.008, 0.08));
                float d2 = B(p, float2(0.08, 0.008));
                d = metal::min(d, d2);
                return d;
            }

            float3 lineGraphicsLayer(float2 p, float3 col, float time, float2 resolution) {
                p.x = abs(p.x);
                p.y += time * 0.08;
                p *= 4.0;
                
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;

                float n = random(id);
                gr *= Rot(radians(90.0 * metal::step(0.5, n)));

                float lineWidth = 0.008;
                float3 lineColor = float3(0.8);
                gr *= Rot(radians(45.0));
                gr.x = abs(gr.x) - 0.707;
                float d = circleAnimation(gr, 0.14, lineWidth, -1.0, 2.0, time);
                col = metal::mix(col, lineColor, metal::smoothstep(0.0001, -0.01, d));
                
                d = abs(abs(metal::length(gr) - 0.5) - 0.09) - lineWidth;
                col = metal::mix(col, lineColor, metal::smoothstep(0.0001, -0.01, d));

                d = circleAnimation(gr, 0.03, lineWidth, 1.0, 2.0, time);
                col = metal::mix(col, lineColor, metal::smoothstep(0.0001, -0.01, d));

                d = abs(abs(metal::length(gr) - 0.5) - 0.19) - lineWidth;
                col = metal::metal::mix(col, lineColor, metal::smoothstep(0.0001, -0.01, d));
                
                return col;
            }

            float3 lineGraphicsLayer2(float2 p, float3 col, float time, float2 resolution) {
                p.y += time * 0.08;
                p *= 4.0;
                p -= 0.5;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;

                float n = random(id);

                float lineWidth = 0.008;
                float3 lineColor = float3(0.8);

                float d = circleAnimation(gr, 0.35, lineWidth, 1.0, 1.5, time) * metal::step(0.5, n);
                float d2 = circleAnimation(gr, 0.3, lineWidth, -1.0, 1.5, time) * metal::step(0.5, n);
                d = metal::min(d, d2);
                d2 = graphicItem3(gr) * (1.0 - metal::step(0.5, n));
                d = metal::min(d, d2);
                col = metal::mix(col, lineColor, metal::smoothstep(0.0001, -0.01, d));

                return col;
            }

            float3 graphicItem1Layer(float2 p, float3 col, float time, float2 resolution) {
                p.x = abs(p.x) - 0.3;
                p.y += time * 0.15;
                p.y += 0.2;
                p *= 2.1;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = random(id);
                gr.x += metal::sin(n * 10.0) * 0.1;
                gr.y += metal::sin(n * 10.0) * 0.1 + metal::step(0.9, n);
                gr *= Rot(n * 2.0);
                gr *= metal::clamp(n * 2.5, 0.85, 2.5);
                col = graphicItem1(gr, col, time, resolution);
                
               
                return col;
            }

            float3 graphicItem0Layer2(float2 p, float3 col, float time, float2 resolution) {
                p.x = abs(p.x) - 0.12;
                p.y += time * 0.12;
                p *= 2.0;
                float2 id = floor(p);
                float2 gr = fract(p) - 0.5;
                
                float n = random(id);
                gr.x += metal::sin(n * 2.0) * 0.25;
                gr.y += metal::sin(n * 2.0) * 0.3 + metal::step(0.9, n);
                gr *= metal::clamp(n * 1.5, 0.6, 1.5);
                col = graphicItem0(gr, col, resolution);
                
                return col;
            }

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
    
    
    static let defaultFragmentShader: String = commonShaderSource + functions + """
    fragment float4 defaultFragmentShader(VertexOutput in [[stage_in]],
                                               constant Viewport& viewport [[buffer(0)]],
                                                constant ShaderInput &shaderInput [[buffer(1)]]) {
         
            float3 col = float3(0.0);
              
            col = graphicItem2Layer(in.screenCoord, col, shaderInput.time, viewport.size); //spinning transparent shapes
            col = lineGraphicsLayer(in.screenCoord, col, shaderInput.time, viewport.size); //background
            col = lineGraphicsLayer2(in.screenCoord, col, shaderInput.time, viewport.size); //+ on the background
            col = graphicItem0Layer(in.screenCoord, col, shaderInput.time, viewport.size); //triple putkula
            col = graphicItem0Layer2(in.screenCoord, col, shaderInput.time, viewport.size); //single putkula
            col = graphicItem1Layer(in.screenCoord, col, shaderInput.time, viewport.size); //transparent non spinning
    
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

