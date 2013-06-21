package com.hgf;

import box2D.common.math.B2Vec2;

/**
 * Common configuration for the Box2D engine.
 * 
 * @author Alex FRENE
 * @since 20/06/2013
 */
class PhysicsConfig
{
	/** The engine gravity */
	public static var gravity:B2Vec2 = new B2Vec2(0, 10);
	
	/** The physics display ratio */
	public static var displayRatio:Float = 30.0;
}