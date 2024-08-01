#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our textures.
layout(rgba8, set = 0, binding = 0) uniform restrict image2D previousImage;
layout(rgba8, set = 1, binding = 0) uniform restrict readonly image2D brushImage;

layout(push_constant, std430) uniform BrushParams {
	vec4 color;
	vec2 size;
    vec2 position;
} brushParams;

// The code we want to execute in each invocation
void main() {
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);
    vec4 outputColor = imageLoad(previousImage, UV).rgba;
    vec4 brushColor = imageLoad(brushImage,UV).rgba;

    float dist = (distance(UV,brushParams.position));

    vec4 outColor = outputColor;

    if (dist <= brushParams.size.x){
        outColor = brushParams.color;
    }

    imageStore(previousImage, UV, outColor.rgba);
}