package lighting;

import flixel.graphics.shaders.tiles.FlxTexturedShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.util.FlxColor;

/**
 * Class for the creation of a Lighting object that handles the interfacing with the embedded lighting fragment shader
 * @author George Baron
 */
class FlxLighting extends FlxTexturedShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
		"
		// default shader variables and uniforms
		varying vec2 vTexCoord;
		varying vec4 vColor;
		varying vec4 vColorOffset;
		uniform sampler2D uImage0;
		
		//Lights
		uniform mat4 light0;
		uniform mat4 light1;
		uniform mat4 light2;
		uniform mat4 light3;
		uniform mat4 light4;
		uniform mat4 light5;
		uniform mat4 light6;
		uniform mat4 light7;
		//Ambient
		uniform vec3 ambient;
		uniform float ambientIntensity;
		
		//Normal map
		uniform sampler2D normalMap;
		
		//Resolution
		uniform vec2 resolution;
		
		vec3 calcLight(mat4 light, vec3 N)
		{
			if (light[0].w == 0.0)
				return vec3(0.0);
			
			//Distance calculations
			vec3 deltaPos = vec3((light[0].xy - gl_FragCoord.xy) / resolution, light[0].z);
			vec3 lightDir = normalize(deltaPos);
			float lambert = clamp(dot(N, lightDir), 0.0, 1.0);
			
			//Attenuation (aka light falloff)
			float d = sqrt(dot(deltaPos, deltaPos));
			float att = 1.0 / (light[2].x + (light[2].y * d) + (light[2].z * pow(d, 2)));
			
			//TODO: blur edges of spotlights
			if (light[3].z > 0.0)
			{
				float fragAngle = degrees(acos(dot(-lightDir, normalize(vec3((light[3].xy - gl_FragCoord.xy) / resolution, 0.0)))));
				
				if (fragAngle > light[3].z)
					att = 0.0;
			}
			
			//Finalising light colour
			return light[1].rgb * lambert * att * light[0].w;
		}
		
		void main()
		{
			vec4 original = texture2D(uImage0, vTexCoord);
			vec4 normal = texture2D(normalMap, vTexCoord);
			
			if (normal.rgb == vec3(0.0))
			{
				gl_FragColor = original;
				return;
			}
			
			//Flipping the y component
			normal.g = 1.0 - normal.g;
			
			//Normalising and fitting normals to range [0...1]
			vec3 N = normalize(normal.rgb * 2.0 - 1.0);
			
			//Combining all of the lights
			float denom = ceil(light0[0].w) + ceil(light1[0].w) + ceil(light2[0].w) + ceil(light3[0].w)
						+ ceil(light4[0].w) + ceil(light5[0].w) + ceil(light6[0].w) + ceil(light7[0].w);
			
			vec3 av = calcLight(light0, N)
					+ calcLight(light1, N)
					+ calcLight(light2, N)
					+ calcLight(light3, N)
					+ calcLight(light4, N)
					+ calcLight(light5, N)
					+ calcLight(light6, N)
					+ calcLight(light7, N);
			
			av /= denom;
			
			vec3 composite = original.rgb * (ambient * ambientIntensity) + clamp(av, 0, 1);
			
			gl_FragColor = vec4(composite, 1.0);
		}";
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		super(null, DEFAULT_FRAGMENT_SOURCE);
	}
}