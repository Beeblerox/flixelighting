package lighting;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.Lib;

private typedef Spotlight =
{
	var width:Float;
	var target:FlxPoint;
}

private typedef Attenuation =
{
	var constant:Float;
	var linear:Float;
	var quadratic:Float;
}

/**
 * Class for the creation of a light object to be passed into a Lighting object
 * @author George Baron
 */
class FlxLight extends FlxSprite
{
	/**
	 * The z-position of the light
	 */
	public var z:Float;
	/**
	 * The intensity of the light from 0.0 - 1.0 (Gets clamped between these values otherwise)
	 */
	public var intensity:Float;
	/**
	 * The color of the light
	 */
	public var lightColor:FlxColor;
	
	private var attenuation:Attenuation;
	private var spotlight:Spotlight;
	
	private var lightMatrix:Array<Float>;
	
	/**
	 * Constructor
	 * @param	X	The x-position of the light
	 * @param	Y	The y-position of the light
	 * @param	Z	The z-position of the light
	 * @param	Intensity	The intensity of the light from 0.0 - 1.0 (Gets clamped between these values otherwise)
	 * @param	Color	The color of the light
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?Z:Float = 0, ?Intensity:Float = 1, ?Color:FlxColor = FlxColor.WHITE)
	{
		super(X, Y);
		
		z = Z;
		intensity = Intensity;
		lightColor = Color;
		attenuation = { constant: 0.4, linear: 3.0, quadratic: 20.0 };
		spotlight = { width: 0.0, target: new FlxPoint(0.0, 0.0) };
		
		makeGraphic(10, 10, FlxColor.TRANSPARENT);
		
		lightMatrix = [for (i in 0...16) 0.0];
	}
	
	/**
	 * Convert the light into a spotlight
	 * @param	Width	The width of the spotlight
	 * @param	TargetX	The target's x-position
	 * @param	TargetY	The target's y-position
	 */
	public function makeSpotlight(Width:Float, TargetX:Float, TargetY:Float):Void
	{
		spotlight.width = Width;
		spotlight.target.set(TargetX, TargetY);
	}
	
	/**
	 * Sets the target of the spotlight (if the light isn't a spotlight, this will do nothing)
	 * @param	TargetX	The target's x-position
	 * @param	TargetY	The target's y-position
	 */
	public function setTarget(TargetX:Float, TargetY:Float):Void
	{
		if (spotlight.width > 0)
			spotlight.target.set(TargetX, TargetY);
	}
	
	/**
	 * Set the attenuation (fall-off) of the light
	 * @param	X	The constant attenuation
	 * @param	Y	The linear attenuation
	 * @param	Z	The quadratic attenuation
	 */
	public function setAttenuation(?Constant:Float = 0.0, ?Linear:Float = 0.0, ?Quadratic:Float = 0.0):Void
	{
		attenuation.constant = Constant;
		attenuation.linear = Linear;
		attenuation.quadratic = Quadratic;
	}
	
	/**
	 * Helper function for the shader that returns all the data for the light packed into a matrix
	 * @return All the data for the light packed into a matrix
	 */
	public function getMatrix():Array<Float>
	{
		var screenWidth:Float = Lib.current.stage.stageWidth;
		var screenHeight:Float = Lib.current.stage.stageHeight;
		
		lightMatrix[0] = screenWidth * (x / FlxG.width);
		lightMatrix[1] = screenHeight * (screenHeight - y) / FlxG.height; // invert light's y position
		lightMatrix[2] = z;
		lightMatrix[3] = Math.min(1.0, Math.max(0.0, intensity));
		
		lightMatrix[4] = lightColor.redFloat;
		lightMatrix[5] = lightColor.greenFloat;
		lightMatrix[6] = lightColor.blueFloat;
		lightMatrix[7] = 1.0;
		
		lightMatrix[8] = attenuation.constant;
		lightMatrix[9] = attenuation.linear;
		lightMatrix[10] = attenuation.quadratic;
		lightMatrix[11] = 0.0;
		
		lightMatrix[12] = screenWidth * (spotlight.target.x / FlxG.width);
		lightMatrix[13] = screenHeight * (spotlight.target.y / FlxG.height);
		lightMatrix[14] = spotlight.width;
		lightMatrix[15] = 0.0;
		
		return lightMatrix;
	}
	
}