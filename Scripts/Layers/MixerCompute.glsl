#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our textures.
layout(rgba8, set = 0, binding = 0) uniform restrict image2D previousLayerImage;
layout(rgba8, set = 1, binding = 0) uniform restrict readonly image2D currentLayerImage;
layout(r8, set = 2, binding = 0) uniform restrict readonly image2D currentLayerMask;

layout(push_constant, std430) uniform LayerParams {
	uvec2 textureSize; //Resoulution of the texture
    int mixMode;
	float opacity; //between 0.0 - 1.0
} layerParams;

// The code we want to execute in each invocation
void main() {
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);
    vec4 outputColor = imageLoad(previousLayerImage, UV).rgba;
    vec4 inputColor = imageLoad(currentLayerImage,UV).rgba;
    float mask = imageLoad(currentLayerMask,UV).r;

//  Mixes between previous layer stack output 0, and inputColor from the next layer 1
// with mask as a parameter.

    //mixMode == overlay
    vec4 operationMix = mix(outputColor,inputColor,mask);

    vec4 resultRGBA = mix(outputColor,operationMix,layerParams.opacity);

    imageStore(previousLayerImage, UV, resultRGBA);
    // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
}