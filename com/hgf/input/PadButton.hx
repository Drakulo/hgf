package com.hgf.input;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.system.input.FlxTouch;

/**
 * Simple button to manage the "pressed" state. The graphics used are the same as
 * a classic FlxButton : 3 sprites with the states "normal", "hovered" and "pressed". 
 * Only "default" ans "pressed" states will be used.
 * 
 * @author Alex FRENE
 */
class PadButton extends FlxSprite
{
	public var pressed:Bool;
	
	public function new(asset:String) 
	{
		super();
		loadGraphic(asset, true, false, 110, 112);
		pressed = false;
	}
	
	public override function update() : Void
	{
		super.update();
		
		var point:FlxPoint = new FlxPoint();
		var actionDetected:Bool = false;
		
		// Handle mouse (for debug)
		#if !FLX_NO_MOUSE
			FlxG.mouse.getScreenPosition(null, point);
			if (FlxG.mouse.pressed() && overlapsPoint(point))
			{
				actionDetected = true;
				frame = 2; // Pressed state
				pressed = true;
			}
		#end
		
		// Handle touch
		#if !FLX_NO_TOUCH
			for (j in 0...FlxG.touchManager.touches.length)
			{
				var touch:FlxTouch = FlxG.touchManager.touches[j];
				touch.getScreenPosition(null, point);
				if (overlapsPoint(point))
				{
					actionDetected = true;
					frame = 2; // Pressed state
					pressed = true;
				}
			}
		#end
		
		if (!actionDetected)
		{
			frame = 0; // Default state
			pressed = false;
		}
	}
}