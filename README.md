# ShaderView

This package is for displaying metal shaders in swiftUI. Suitable for displaying custom shaders from .metal files.

#ShaderView
### ShaderView()
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

#Metal
### Metal code integration 
When using only one of the default shaders (defaultFragmentShader or defaultVertexShader) it is crucial to match output of the vertex shader to input of the fragment shader. Here are some default layouts which will ensure that your shaders will work with the package especially when you choose to only use one of the default shaders. 
#### Definitions of structs used by both default shaders
These are required to be added to your metal code if you choose to use either of the shader templates below.
-  `VertexOutput`: Default vertex shaders output and default fragment shaders expected input.
  ```
struct VertexOutput {
    float4 position [[position]];
    float2 screenCoord;
};
```
- `ViewPort:`Default viewport structure for size, required input by both default shaders at buffer position 0
  

**struct** Viewport {

    float2 size; // This will store the resolution (width, height)

};

#### Default ShaderInput struct
This is only required if you decide to use default fragment shader but custom vertex shader. Can also work as template for a custom ShaderInput structs.
```
struct ShaderInput {

    float time;

};
```

#### Default definition of fragment shader 
Here is a template that ensures compatibility with the packages default vertex shader. 
  ```
fragment float4 customFragmentShader(VertexOutput in [[stage_in]],
                              constant Viewport& viewport [[buffer(0)]],
                              constant ShaderInput& shaderInput [[buffer(1)]]){
    // Shader logic... 
    return float4(red, green, blue, alpha); //Standard return format
}
```
#### Default definition of vertex shader
Here is a template that ensures compatibility with the packages default fragment shader.
```
vertex VertexOutput customVertexShader(uint vertexID [[vertex_id]],
                                     constant Viewport& viewport [[buffer(0)]]) {
    // Shader logic... 
    return VertexOutput; //Standard return format compatable with the default fragment shader
}
```


## Extended Features and Customizations:
