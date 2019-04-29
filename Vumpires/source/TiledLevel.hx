package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap 
{
	public var coll:FlxTilemapExt;
	public var wallsLayer:FlxGroup;
	public var background:FlxGroup;
	public var foreground:FlxGroup;
	private var collidableTileLayers:Array<FlxTilemap>;
	public var playerStart:FlxPoint;
	public var enemies:Array<FlxSprite>;

	public function new(data:FlxTiledMapAsset, ?rootPath:String) 
	{
		super(data, rootPath);
		
		wallsLayer = new FlxGroup();
		background = new FlxGroup();
		foreground = new FlxGroup();
		playerStart = FlxPoint.get();
		enemies = new Array<FlxSprite>();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		var t:TiledTileLayer = cast layerMap.get("walls");
		
		var tS:TiledTileSet = tilesets.get("tmp-tiles");
		
		var tileMap:FlxTilemapExt = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + tS.imageSource), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);
				
		for (tileProp in tS.tileProps)
		{
			if (tileProp != null)
			{
				if (tileProp.keys.exists("cloud"))
				{
					if (tileProp.get("cloud") == "true")
					{
						tileMap.setTileProperties(tS.toGid(tileProp.tileID), FlxObject.UP);
					}
				}
			}
		}
		
		collidableTileLayers = new Array<FlxTilemap>();
		collidableTileLayers.push(tileMap);
		coll = tileMap;
		
		wallsLayer.add(tileMap);
		
		t = cast layerMap.get("background");
		tileMap = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + tS.imageSource), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);

		t = cast layerMap.get("foreground");
		tileMap = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + tS.imageSource), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);
		
		foreground.add(tileMap);
		
		var o:TiledObjectLayer = cast layerMap.get("objects");
		for (j in o.objects)
		{
			
			switch (j.type.toLowerCase()) 
			{
				case "player_start":
					playerStart.x = j.x + (j.width/2);
					playerStart.y = j.y + (j.height);
				case "enemy_1":
					var v:Vumpire = new Vumpire();
					v.x = j.x;
					v.y = j.y;
					enemies.push(v);
				case "enemy_2":
					var b:BallBat = new BallBat();
					b.x = j.x + (j.width/2);
					b.y = j.y - j.height + (j.height / 2);
					enemies.push(b);	
				case "enemy_3":
					var s:StandVump = new StandVump();
					s.x = j.x + (j.width/2);
					s.y = j.y;
					enemies.push(s);	
				default:
					
			}
			
		}
		
	}
	
	public function collideWithLevel(obj:FlxBasic):Bool
	{
		for (map in collidableTileLayers)
		{
			//if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			//{
			//	return true;
			//}
			FlxG.collide(coll, obj);
		}
		return false;
	}
	
	
}