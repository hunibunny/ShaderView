# ShaderView

This package is for displaying metal shaders in swiftUI. Suitable for displaying custom shaders from .metal files.


### ShaderView() 
#ShaderView
`ShaderView()` allows you to display any shader defined in a `.metal` file. To use your custom shader, simply specify the name of the shader when initializing `ShaderView`
#### Basic usage
```swift
ShaderView()
```
#### Parameters
- `fragmentShaderName`: Optional String. Name of the fragment shader. Defaults to a standard shader if not provided. 
- `vertexShaderName`: Optional String. Name of the vertex shader. Defaults to a standard shader if not provided. 
- `fallbackView`: Optional View. A view displayed in case of an error. Defaults to `FallbackView()` if not provided. 
- `placeholderView`: Optional View. A view displayed while shaders are loading. Defaults to `PlaceholderView()` if not provided. 
- `shaderInput`: Optional ShaderInputProtocol. The input for the shader. Defaults to a new instance of `ShaderInput()` if not provided. 

#### Default ShaderInput struct in swift
This is only required if you decide to use default fragment shader but custom vertex shader. Can also work as template for a custom ShaderInput structs.
```swift
struct ShaderInput {
    float time;
};
```

### Metal code integration
#Metal
When using only one of the default shaders (defaultFragmentShader or defaultVertexShader) it is crucial to match output of the vertex shader to input of the fragment shader. Here are some default layouts which will ensure that your shaders will work with the package especially when you choose to only use one of the default shaders. 
#### Definitions of structs needed for package
These structs are used by my package to pass information to shaders. They must be included in .metal files when using custom shaders.
-  `VertexOutput`: Default vertex shaders output and default fragment shaders expected input.
```metal
struct VertexOutput {
    float4 position [[position]];
    float2 screenCoord;
};
```
- `ViewPort:`Default viewport structure for size, required input by both default shaders at buffer position 0.
```metal
struct Viewport {
    float2 size; 
};
```
#### Default definition of fragment shader 
Here is a template that ensures compatibility with the package.
  ```metal
fragment float4 customFragmentShader(VertexOutput in [[stage_in]],
                              constant Viewport& viewport [[buffer(0)]],
                              constant ShaderInput& shaderInput [[buffer(1)]]){
    // Shader logic... 
    return float4(red, green, blue, alpha); //Standard return format
}
```
#### Default definition of vertex shader
Here is a template that ensures compatibility with the package.
```metal
vertex VertexOutput customVertexShader(uint vertexID [[vertex_id]],
                                     constant Viewport& viewport [[buffer(0)]]) {
    // Shader logic... 
    return VertexOutput; //Standard return format compatable with the default fragment shader
}
```


## Customizing shader input:
#ShaderInput

### ShaderInputProtocol

Any shader input has to conform to this protocol. It requires methods used by the package for converting data to metal friendly form, and managing its changes. 

#### Example code of using the protocol
```swift
class ShaderInputProtocolExample: ShaderInputProtocol {

    var time: Float = 0.0
    var onChange: (() -> Void)?
    
    //New variable example. Changing this value triggers the 'onChange' closure, allowing the shader to respond to changes in its active state.
    var isActive: Bool = true{
        didSet{
            onChange?()
        }
    }

    required init(time: Float){
        self.time = time
        self.isActive = true
    }

    func updateProperties(from input: any ShaderInputProtocol){
        guard let input = input as? ShaderInputProtocolExample else {
            return
        }
        self.isActive = input.isActive;

    }

    func metalData() -> Data {
        var metalInput = CustomMetalShaderInput(time: self.time, isActive: self.isActive)
        return Data(bytes: &metalInput, count: MemoryLayout<CustomMetalShaderInput>.size)
    }
}
```

#### Example code of subclassing the default shaderInput
```swift
class SubclassedShaderInput: ShaderInput {

    //New variable example. Changing this value triggers the 'onChange' closure, allowing the shader to respond to changes in its active state.
    var isActive: Bool {
           didSet {
               onChange?()
           }
       }

    required init(time: Float) {
        self.isActive = true
        super.init(time: time)
    }

    override func updateProperties(from input: any ShaderInputProtocol){
        guard let input = input as? SubclassedShaderInput else {
            return
        }
        self.isActive = input.isActive;
    }

    override func metalData() -> Data {
        var metalInput = CustomMetalShaderInput(time: self.time, isActive: self.isActive)
        return Data(bytes: &metalInput, count: MemoryLayout<CustomMetalShaderInput>.size)
    }
}
```

#### Example on custom shader input data
For metal to be able to read shader input data correctly, the buffer sizes and expectations need to match. It's recommended to define custom shader input struct that also can be defined in metal. 
-Note: Sometimes same type of variables have different sizes in swift and metal, and buffers don't match. Padding can be used to fix this problem of different size of buffers on passing data to shaders.
##### Example of passing custom shader 
This example is compatible with SubclassedShaderInput and ShaderInputProtocolExample from above.
```swift
struct CustomMetalShaderInput {
    var time: Float
    var isActive: Bool
    var padding: [UInt8] = Array(repeating: 0, count: 3) //needed for difference in size of boolean in swift vs metal
}
```
