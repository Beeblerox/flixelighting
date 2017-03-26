package lighting;

import flixel.FlxG;
import flixel.graphics.FlxMaterial;
import flixel.util.FlxColor;

class FlxLightingMaterial extends FlxMaterial
{
	private var lights:Array<LightRef>;
	private var u_ambient:Array<Float>;
	private var u_ambientIntensity:Array<Float>;
	
	private var u_resolution:Array<Float>;
	
	public function new() 
	{
		super();
		
		shader = new FlxLighting();
		
		u_ambient = [0.0, 0.0, 0.0];
		u_ambientIntensity = [0.25];
		
		u_resolution = [1.0, 1.0];
		
		updateUniforms();
		
		lights = [for (i in 0...8) { identifier: i, light: null }];
	}
	
	/**
	 * Mutator method for setting the color and intensity of the ambient light
	 * @param	Color	The color of the ambient light
	 * @param	Intensity	The intensity of the ambient light
	 */
	public function setAmbient(Color:FlxColor = FlxColor.BLACK, ?Intensity:Float = 1.0):Void
	{
		u_ambient[0] = Color.redFloat;
		u_ambient[1] = Color.greenFloat;
		u_ambient[2] = Color.blueFloat;
		
		u_ambientIntensity[0] = Intensity;
		
		updateUniforms();
	}
	
	/**
	 * Method for adding a normal map to the lighting calculations
	 * NOTE: A normal map MUST be added for the lighting to function
	 * @param	normalMap	The normal map to be used in calculations
	 */
	public function addNormalMap(normalMap:FlxNormalMap):Void
	{
		u_resolution[0] = normalMap.data.width;
		u_resolution[1] = normalMap.data.height;
		
		data.resolution.value = u_resolution;
		setTexture("normalMap", normalMap.data);
	}
	
	/**
	 * Method for adding a light to the lighting calculations
	 * NOTE: A max of 8 lights can be added!
	 * @param	light	The light to be used in calculations
	 */
	public function addLight(light:FlxLight):Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light == null)
			{
				lights[i].light = light;
				passInto(lights[i].identifier, light);
				break;
			}
			else if (i == lights.length - 1)
				trace("Error: You can only add a maximum of 8 lights to the scene!");
		}
	}
	
	/**
	 * Method for removing a light from the lighting calculations
	 * @param	light	The light to be removed from the lighting calculations
	 */
	public function removeLight(light:FlxLight):Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light == light)
			{
				lights[i].light = null;
				passInto(lights[i].identifier, new FlxLight(0.0, 0.0, 0.0, 0.0));
				break;
			}
		}
	}
	
	/**
	 * Method used to recalculate the lighting
	 */
	public function update():Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light != null)
				passInto(lights[i].identifier, lights[i].light);
		}
	}
	
	private function updateUniforms():Void
	{
		data.ambient.value = u_ambient;
		data.ambientIntensity.value = u_ambientIntensity;
	}
	
	private function passInto(identifier:Int, l:FlxLight):Void
	{
		switch (identifier)
		{
			case 0: data.light0.value = l.getMatrix();
			case 1: data.light1.value = l.getMatrix();
			case 2: data.light2.value = l.getMatrix();
			case 3: data.light3.value = l.getMatrix();
			case 4: data.light4.value = l.getMatrix();
			case 5: data.light5.value = l.getMatrix();
			case 6: data.light6.value = l.getMatrix();
			case 7: data.light7.value = l.getMatrix();
		}
	}
}

typedef LightRef =
{
	@optional var identifier:Int;
	@optional var light:FlxLight;
}