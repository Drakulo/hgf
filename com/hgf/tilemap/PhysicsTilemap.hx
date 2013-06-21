package com.hgf.tilemap;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import com.hgf.PhysicsState;
import nme.Assets;
import org.flixel.FlxCamera;
import org.flixel.FlxGroup;
import org.flixel.FlxTilemap;
import org.flixel.tmx.TmxMap;
import org.flixel.tmx.TmxObject;
import org.flixel.tmx.TmxObjectGroup;

/**
 * Custom Tilemap system basd on Box2D.
 * 
 * @author Alex FRENE
 * @since 20/06/2013
 */
class PhysicsTilemap extends FlxGroup
{
	/** The map definition layer */
	private var _layerName:String;
	/** The tileset name defined in the map settings */
	private var _tilesetName:String;
	/** The box2D object layer name */
	private var _box2dLayerName:String;
	/** The tileset ID */
	private var _tilesetId:String;
	/** The tile width */
	private var _tileWidth:Int;
	/** The tile height */
	private var _tileHeight:Int;
	
	/** The game state reference*/
	private var _physicsState:PhysicsState;
	/** The tiled map asset ID */
	private var _mapId:String;
	/** The Box2D world */
	private var _world:B2World;
	/** The tilemap used for rendering */
	private var _tilemap:FlxTilemap;
	
	
	public function new(mapId:String, tilesetId:String, tileWidth:Int, tileHeight:Int, world:B2World) 
	{
		super();
		
		_mapId = mapId;
		_tilesetId = tilesetId;
		_tileWidth = tileWidth;
		_tileHeight = tileHeight;
		_world = world;
		
		// Default parameters may be overriden in subclasses
		_layerName = "map";
		_tilesetName = "tileset";
		_box2dLayerName = "blocks";
	}
	
	/**
	 * Load the tiled map and initialize Box2D blocks.
	 */
	public function loadMap() : Void
	{
		// Load the map via TMX
		var tmxMap:TmxMap = new TmxMap(Assets.getText(_mapId));
		var csvData:String = tmxMap.getLayer(_layerName).toCsv(tmxMap.getTileSet(_tilesetName));
		
		// Create the tilemap
		_tilemap = new FlxTilemap();
		_tilemap.loadMap(csvData, _tilesetId, _tileWidth, _tileHeight, FlxTilemap.OFF);
		add(_tilemap);
		
		// Create the Box2D blocks
		var blockLayer:TmxObjectGroup = tmxMap.getObjectGroup(_box2dLayerName);
		if (blockLayer != null)
		{
			var block:TmxObject = null;
			var x:Int;
			var y:Int;
			var blockWidth:Int;
			var blockHeight:Int;
			var xPadd:Int;
			var yPadd:Int;
			for (i in 0...blockLayer.objects.length)
			{
				// Get block data
				block = cast(blockLayer.objects[i], TmxObject);
				blockWidth = block.width;
				blockHeight = block.height;
				
				// Compute the padding to align the block to a tile
				xPadd = (block.x % _tileWidth);
				yPadd = (block.y % _tileHeight);
				
				x = block.x - xPadd;
				y = block.y - yPadd;
				blockWidth += xPadd;
				blockHeight += yPadd;
				
				// Adjust block width to align to a tile
				blockWidth = (Math.floor(blockWidth / _tileWidth) + 1) * _tileWidth;
				blockHeight = (Math.floor(blockHeight / _tileHeight) + 1) * _tileHeight;
				
				// Add border settings
				// TODO
				
				createBlock(x, y, blockWidth, blockHeight);
			}
		}
		else
		{
			trace("Missing layer " + _box2dLayerName + " defining box2D blocks!");
		}
	}
	
	/**
	 * Simple wrapper for the tilemap follow function.
	 */
	public function follow(camera:FlxCamera = null, border:Int = 0, updateWorld:Bool = true) : Void
	{
		_tilemap.follow(camera, border, updateWorld);
	}
	
		/**
	 * Create a Box2D static block and add it to the world.
	 * 
	 * @param	x : X position of the block (top left)
	 * @param	y : Y position of the block (top left)
	 * @param	width : The block width
	 * @param	height : The block height
	 */
	private function createBlock(x:Int, y:Int, width:Int, height:Int) : Void
	{
		var ratio:Float = PhysicsConfig.displayRatio;
		var boxShape:B2PolygonShape = new B2PolygonShape();
		boxShape.setAsBox((width / 2) / ratio, (height / 2) / ratio);

		var fixDef = new B2FixtureDef();
		fixDef.shape = boxShape;
		
		var bodyDef = new B2BodyDef();
		bodyDef.position.set((x + (width/2)) / ratio, (y + (height/2)) / ratio);
		bodyDef.type = B2Body.b2_staticBody;
		
		var obj:B2Body = _world.createBody(bodyDef);
		obj.createFixture(fixDef);
	}
}