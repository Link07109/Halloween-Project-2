#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 finalColor;

const float curvature = 10.0;
const float vignette_width = 30.0;

const vec2 size = vec2(1344, 864);  // render size

uniform sampler2D texture0;
uniform vec4 colDiffuse;

void main() {
    // curvature
    vec2 uv = fragTexCoord * 2.0 - 1.0;
    vec2 offset = uv.yx / curvature;
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;

    finalColor = texture(texture0, uv) * fragColor;

    // make out of bounds pixels black
    if (uv.x <= 0.0 || 1.0 <= uv.x || uv.y <= 0.0 || 1.0 <= uv.y) {
        finalColor = vec4(0.0);
    }

    // vignette
    uv = uv * 2.0 - 1.0;
    vec2 vignette = vignette_width / size.xy;
    vignette = smoothstep(vec2(0.0), vignette, 1.0 - abs(uv));
    vignette = clamp(vignette, 0.0, 1.0);

    // scanlines
    finalColor.g *= (sin(fragTexCoord.y * size.y * 2.0) + 1.0) * 0.15 + 1.0;
    finalColor.rb *= (cos(fragTexCoord.y * size.y * 2.0) + 1.0) * 0.135 + 1.0;

    finalColor = clamp(finalColor, 0.0, 1.0) * vignette.x * vignette.y * colDiffuse;
}
