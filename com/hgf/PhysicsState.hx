package com.hgf;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import nme.display.Sprite;
import nme.Lib;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import org.flixel.FlxG;
import org.flixel.FlxState;

/**
 * State managing a Box2D world.
 * 
 * @author Drakulo
 * @since 18/06/2013
 */
class PhysicsState extends FlxState
{
	/** The physics world */
	var _world:B2World;
	
	/** The sprite used to draw physics debug data */
	private var _worldDebug:Sprite;
	
	public function getWorld() : B2World { return _world; }
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * Create and initialize the world.
	 */
	public override function create() : Void
	{
		super.create();
		
		initialize();
	}
	
	/**
	 * Clear the world from its bodies.
	 */
	public override function destroy() : Void
	{
		super.destroy();
		
		_world = null;
	}
	
	/**
	 * Perform the update loop.
	 */
	public override function update() : Void
	{
		super.update();
		
		_world.step(FlxG.elapsed, 10, 10);
		_world.clearForces();
		_world.drawDebugData();
		
		_worldDebug.x = -FlxG.camera.scroll.x;
		_worldDebug.y = -FlxG.camera.scroll.y;
	}
	
	/**
	 * Initialize common data in the state.
	 */
	function initialize() : Void
	{
		_worldDebug = new Sprite();
		_worldDebug.alpha = 0.4;
		
		// Create the world
		_world = new B2World(PhysicsConfig.gravity, true);
		
		// Create the debug draw
		var debugDraw:B2DebugDraw = new B2DebugDraw();
		debugDraw.setSprite(_worldDebug);
		debugDraw.setDrawScale(PhysicsConfig.displayRatio);
		debugDraw.setFlags(B2DebugDraw.e_shapeBit);
		_world.setDebugDraw(debugDraw);
		
		// Add the debug sprite to the stage
		Lib.current.addChild(_worldDebug);
	}

}