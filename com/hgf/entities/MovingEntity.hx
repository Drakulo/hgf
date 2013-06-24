package com.hgf.entities;

import org.flixel.FlxSprite;

/**
 * Represents a non static entity affected by gravity.
 * 
 * @author Alex FRENE
 */
class MovingEntity extends FlxSprite
{

	public function new(gravity:Float, x:Float = 0, y:Float = 0, simpleGraphic:Dynamic = null) 
	{
		super(x, y, simpleGraphic);
		acceleration.y = gravity;
	}
	
}