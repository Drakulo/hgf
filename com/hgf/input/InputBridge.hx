package com.hgf.input;

import com.hgf.input.CustomPad;
import org.flixel.FlxG;

/**
 * This static class is a wrapper for the different input types : mobile / desktop.
 * 
 * @author Alex FRENE
 */
class InputBridge
{
	/** The game pad for mobile devices */
	public static var gamepad:CustomPad;
	
	/** Stick / Keyboard input values */
	public static var left(default, null)  : Bool;
	public static var right(default, null)  : Bool;
	public static var up(default, null)  : Bool;
	public static var down(default, null)  : Bool;
	
	/** Stick analogic strength. These values are set to 1 for desktop */
	public static var leftStrength(default, null)  : Float;
	public static var rightStrength(default, null)  : Float;
	public static var upStrength(default, null)  : Float;
	public static var downStrength(default, null)  : Float;
	
	public static var actionA(default, null)  : Bool;
	//public static var actionB(default, null)  : Bool;
	
	/**
	 * Update the input values according to the game mode (mobile / desktop)
	 */
	public static function update() : Void
	{
		resetInput();
		if (gamepad == null)
		{
			handleDesktopInput();
		}
		else
		{
			handleMobileInput();
		}
	}
	
	/**
	 * Reset all inputs.
	 */
	private static function resetInput() : Void
	{
		left = false;
		right = false;
		up = false;
		down = false;
		
		leftStrength = 0;
		rightStrength = 0;
		upStrength = 0;
		downStrength = 0;
		
		actionA = false;
	}
	
	/**
	 * Handle input for desktop : keyboard. Analogic strength are set to 1.
	 */
	private static function handleDesktopInput() : Void
	{
		left = FlxG.keys.LEFT;
		if (left)
		{
			leftStrength = 1;
		}
		
		right = FlxG.keys.RIGHT;
		if (right)
		{
			rightStrength = 1;
		}
		
		up = FlxG.keys.UP;
		if (up)
		{
			upStrength = 1;
		}
		
		down = FlxG.keys.DOWN;
		if (down)
		{
			downStrength = 1;
		}
		
		actionA = FlxG.keys.SPACE;
	}
	
	/**
	 * Handle input for mobile : gamepad.
	 */
	private static function handleMobileInput() : Void
	{
		left = gamepad.stickLeft;
		right = gamepad.stickRight;
		up = gamepad.stickUp;
		down = gamepad.stickDown;
		
		leftStrength = gamepad.leftStrength;
		rightStrength = gamepad.rightStrength;
		upStrength = gamepad.upStrength;
		downStrength = gamepad.downStrength;
		
		actionA = gamepad.buttonA;	
	}
}