package com.alkevi.hgf.tilemap;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import com.alkevi.hgf.PhysicsConfig;
import org.flixel.FlxSprite;

/**
 * This represents a physics entity.
 * 
 * @author Alex FRENE
 * @since 20/06/2013
 */
class PhysicsEntity extends FlxSprite
{
	/** The fixture definition */
	private var _fixDef:B2FixtureDef;
	/** The body definition */
	private var _bodyDef:B2BodyDef;
	/** The physics object */
	private var _obj:B2Body;
	/** The worl reference */
	private var _world:B2World;
	
	// Physics params 
	private var _friction:Float;
	private var _restitution:Float;
	private var _density:Float;
	
	/** The body type (default to dynamic)*/
	public var _type:Int;
	
	public function new(world:B2World, x:Int = 0, y:Int = 0) 
	{
		super(x, y);
		
		_world = world;
		
		// Default values
		_friction = 0.8;
		_restitution = 0.3;
		_density = 0.7;
		_type = B2Body.b2_dynamicBody;
	}
	
	/**
	 * Update the Flixel sprite according to the Box2D physics object.
	 */
	public override function update() : Void
	{
		var position:B2Vec2 = _obj.getPosition();
		x = position.x * PhysicsConfig.displayRatio - width / 2;
		y = position.y * PhysicsConfig.displayRatio - height / 2;
		
		super.update();
	}
	
	/**
	 * Create the Box2D physics body.
	 */
	public function createBody() : Void
	{
		var boxShape:B2PolygonShape = new B2PolygonShape();
		boxShape.setAsBox((width/2) / PhysicsConfig.displayRatio, (height/2) / PhysicsConfig.displayRatio);

		_fixDef = new B2FixtureDef();
		_fixDef.density = _density;
		_fixDef.restitution = _restitution;
		_fixDef.friction = _friction;                        
		_fixDef.shape = boxShape;
		
		_bodyDef = new B2BodyDef();
		_bodyDef.position.set((x + (width/2)) / PhysicsConfig.displayRatio, (y + (height/2)) / PhysicsConfig.displayRatio);
		_bodyDef.type = _type;
		
		_obj = _world.createBody(_bodyDef);
		_obj.createFixture(_fixDef);
	}
	
	/**
	 * Destroy the body and kill the sprite.
	 */
	public override function kill() : Void
	{
		_world.destroyBody(_obj);
		super.kill();
	}
}