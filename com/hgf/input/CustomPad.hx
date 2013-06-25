package com.hgf.input;

import com.hgf.HgfAssets;
import nme.Assets;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxRect;
import org.flixel.FlxText;
import org.flixel.FlxTypedGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxAssets;
import org.flixel.system.input.FlxTouch;

/**
 * Simple pad manager with a left stick and an action button.
 * 
 * @author Alex FRENE
 * @since 18/06/2013
 */
class CustomPad extends FlxTypedGroup<FlxSprite>
{
	/** Rendering padding */
	private var _padding:Float;
	/** The stick */
	private var _stick:FlxSprite;
	/** The default stick X coordinate */
	private var _defaultStickX:Float;
	/** The default stick Y coordinate */
	private var _defaultStickY:Float;
	/** Cache data to save computing */
	private var _stickHalfWidth:Float;
	/** Cache data to save computing */
	private var _stickHalfHeight:Float;
	/** The stick base center point */
	private var _stickBaseCenter:FlxPoint;
	/** The stick center point */
	private var _stickCenter:FlxPoint;
	/** Cache flag to manage stick drag */
	private var _stickWasPressed:Bool;
	/** stick touch detection rectangle */
	private var _stickDetectionRect:FlxObject;
	/** The stick base radius */
	private var _baseRadius:Float;
	/** The X button */
	private var _buttonA:PadButton;
	
	private var debugText:FlxText;
	
	// Input values (properties)
	public var stickLeft(default, null)  : Bool;
	public var stickRight(default, null) : Bool;
	public var stickUp(default, null)    : Bool;
	public var stickDown(default, null)  : Bool;
	
	public var buttonA(buttonAState, null)    : Bool;
	
	// Analogic strength multiplier.
	public var leftStrength(default, null)  : Float;
	public var rightStrength(default, null) : Float;
	public var upStrength(default, null)    : Float;
	public var downStrength(default, null)  : Float;
	
	public function new() 
	{
		super();
		
		stickLeft  = false;
		stickRight = false;
		stickUp    = false;
		stickDown  = false;
		leftStrength  = 0;
		rightStrength = 0;
		upStrength    = 0;
		downStrength  = 0;
		
		_stickWasPressed = false;
		_padding = FlxG.width / 12;
		
		var stickBase = new FlxSprite(_padding, 0, HgfAssets.imgStickBase);
		stickBase.y = FlxG.height - _padding - stickBase.height;
		fixAndAdd(stickBase);
		
		_baseRadius = stickBase.width / 2;
		_stickBaseCenter = new FlxPoint(stickBase.x + stickBase.width / 2, stickBase.y + stickBase.height / 2);
		_stickCenter = new FlxPoint();
		
		_stick = new FlxSprite(0, 0, HgfAssets.imgStick);
		
		// Compute cache data
		_stickHalfWidth = _stick.width / 2;
		_stickHalfHeight = _stick.height / 2;
		
		// Setup default position
		_defaultStickX = _stickBaseCenter.x - _stickHalfWidth;
		_defaultStickY = _stickBaseCenter.y - _stickHalfHeight;
		
		_stick.x = _defaultStickX;
		_stick.y = _defaultStickY;
		fixAndAdd(_stick);
		
		// Buttons
		_buttonA = new PadButton(HgfAssets.imgButtonA);
		_buttonA.x = FlxG.width - _buttonA.width - _padding;
		_buttonA.y = FlxG.height -_buttonA.height - _padding + 9; // Additionnal padding for the button shadow
		fixAndAdd(_buttonA);
		
		debugText = new FlxText(10, 10, 500, "", 16);
		fixAndAdd(debugText);
		
		_stickDetectionRect = new FlxObject(0, FlxG.height / 2, FlxG.width / 2, FlxG.height / 2);
		_stickDetectionRect.scrollFactor.x = _stickDetectionRect.scrollFactor.y = 0;
	}
	
	private function buttonAState() : Bool { return _buttonA.pressed; }
	
	/**
	 * Fix the scroll of a sprite and add it to the group.
	 * 
	 * @param	o : The sprite to add
	 */
	private function fixAndAdd(o:FlxSprite) : Void
	{
		o.solid = false;
		o.immovable = true;
		o.scrollFactor.x = o.scrollFactor.y = 0;
		add(o);
	}
	
	public override function draw() : Void
	{
		super.draw();
		_stickDetectionRect.draw();
	}
	/**
	 * Update method.
	 */
	public override function update() : Void
	{
		// Reset button input
		buttonA = false;
		
		var point:FlxPoint = new FlxPoint();
		var actionDetected:Bool = false;
		
		// Handle mouse (for debug)
		#if !android
		if (FlxG.mouse.pressed())
		{
			FlxG.mouse.getScreenPosition(null, point);
			updateStick(point);
			actionDetected = true;
		}
		#end
		
		// Handle touch
		#if android
			for (j in 0...FlxG.touchManager.touches.length)
			{
				var touch:FlxTouch = FlxG.touchManager.touches[j];
				touch.getScreenPosition(null, point);
				
				// Check if the touched point is near the last touched stick point
				if (_stickDetectionRect.x <= point.x && point.x <= (_stickDetectionRect.x + _stickDetectionRect.width)
					&& _stickDetectionRect.y <= point.y && (_stickDetectionRect.y + _stickDetectionRect.height) >= point.y)
				{
					updateStick(point);
					actionDetected = true;
				}
			}
		#end
		
		// Clamp the stick in the background
		clampStick();
		
		if (!actionDetected)
		{
			//_stickWasPressed = false;
			// Reset stick position
			_stick.x = _defaultStickX;
			_stick.y = _defaultStickY;
			_stickCenter.x = _stick.x + _stickHalfWidth;
			_stickCenter.y = _stick.y + _stickHalfHeight;
		}
		
		computeInput();
		
		super.update();
	}
	
	/**
	 * Compute input flags.
	 */
	private function computeInput() : Void
	{
		// Reset previous values
		stickLeft  = false;
		stickRight = false;
		stickUp    = false;
		stickDown  = false;
		leftStrength  = 0;
		rightStrength = 0;
		upStrength    = 0;
		downStrength  = 0;
		
		// Compute X and Y deltas for analogic strength
		var xDelta:Float = Math.abs(_stickBaseCenter.x - _stickCenter.x);
		var yDelta:Float = Math.abs(_stickBaseCenter.y - _stickCenter.y);
		
		var tolerance:Float = 15;
		if (_stickBaseCenter.y - _stickCenter.y > tolerance)
		{
			// Up
			stickUp = true;
			upStrength = yDelta / _baseRadius;
		}
		else if (_stickCenter.y - _stickBaseCenter.y > tolerance)
		{
			// Down
			stickDown = true;
			downStrength = yDelta / _baseRadius;
		}
		
		if (_stickBaseCenter.x - _stickCenter.x > tolerance)
		{
			// Left
			stickLeft = true;
			leftStrength = xDelta / _baseRadius;
		}
		else if (_stickCenter.x - _stickBaseCenter.x > tolerance)
		{
			// Right
			stickRight = true;
			rightStrength = xDelta / _baseRadius;
		}
	}
	
	/**
	 * Update the stick position.
	 * 
	 * @param	point   : The touched point
	 */
	private function updateStick(point:FlxPoint) : Void
	{
		_stick.x = point.x - _stickHalfWidth;
		_stick.y = point.y - _stickHalfHeight;
		//_stickWasPressed = true;
		_stickCenter.x = _stick.x + _stick.width / 2;
		_stickCenter.y = _stick.y + _stick.height / 2;
	}
	
	/**
	 * Clamp the stick inside the base radius.
	 */
	private function clampStick() : Void
	{
		var vector:FlxPoint = new FlxPoint(_stickCenter.x - _stickBaseCenter.x, _stickCenter.y - _stickBaseCenter.y);
		var length:Float = Math.sqrt(Math.pow(vector.x, 2) + Math.pow(vector.y, 2));
		
		// Apply factor if needed
		if (length > _baseRadius)
		{
			// The stick center is out of the base stick radius, clamp it inside
			var factor:Float = length / _baseRadius;
			vector.x /= factor;
			vector.y /= factor;
			
			_stick.x = _stickBaseCenter.x + vector.x - _stickHalfWidth;
			_stick.y = _stickBaseCenter.y + vector.y - _stickHalfHeight;
		}
	}
}