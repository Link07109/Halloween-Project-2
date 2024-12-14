// manual version of raylib default shader
#version 330       
in vec2 fragTexCoord;              
in vec4 fragColor;                 
out vec4 finalColor;

const vec2 size = vec2(1344, 864);  // render size
const float samples = 5.0;          // pixels per axis; higher = bigger glow, worse performance
const float quality = 4; 	    // lower = smaller glow, better quality

uniform sampler2D texture0;
uniform vec4 colDiffuse;

float offset[3] = float[](0.0, 1.3846153846, 3.2307692308);
float weight[3] = float[](0.2270270270, 0.3162162162, 0.0702702703);

void main()
{
    // blur !
    vec3 texelColor = texture(texture0, fragTexCoord).rgb*weight[0];
    for (int i = 1; i < 3; i++)
    {
	texelColor += texture(texture0, fragTexCoord + vec2(offset[i])/size.x, 0.0).rgb*weight[i];
	texelColor += texture(texture0, fragTexCoord - vec2(offset[i])/size.x, 0.0).rgb*weight[i];
    }

    finalColor = vec4(texelColor, 1.0);

    // scanlines !
    //finalColor = texture(texture0, fragTexCoord) * fragColor; 
    float y = floor(fragTexCoord.y * size.y);
    if (mod(y,4) == 3) {
	finalColor /= 2;    
    }

    // bloom !
    //vec4 sum = vec4(0);
    //vec2 sizeFactor = vec2(1)/size*quality;

    //const int range = (samples - 1)/2;

    //for (int x = -range; x <= range; x++)
    //{
//	for (int y = -range; y <= range; y++)
//	{
//	    sum += texture(texture0, fragTexCoord + vec2(x, y)*sizeFactor);
//	}
  //  }

    //finalColor = ((sum/(samples*samples)) + finalColor)*colDiffuse;
}              
