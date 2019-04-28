package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap 
{
	
	public var wallsLayer:FlxGroup;
	public var background:FlxGroup;
	private var collidableTileLayers:Array<FlxTilemap>;

	public function new(data:FlxTiledMapAsset, ?rootPath:String) 
	{
		super(data, rootPath);
		
		wallsLayer = new FlxGroup();
		background = new FlxGroup();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		
		var t:TiledTileLayer = cast layerMap.get("walls");
		var tS:TiledTileSet = tilesets.get("tmp-tiles");
		
		
		var tileMap:FlxTilemapExt = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + tS.imageSource), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);
		
		collidableTileLayers = new Array<FlxTilemap>();
		collidableTileLayers.push(tileMap);
		
		wallsLayer.add(tileMap);
		
		t = cast layerMap.get("background");
		tileMap = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + tS.imageSource), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);
		
		background.add(tileMap);
		
	}
	
	public function collideWithLevel(obj:FlxBasic, ?notifyCallback:Dynamic->Dynamic->Void, ?processCallback:Dynamic->Dynamic->Bool):Bool
	{
		for (map in collidableTileLayers)
		{
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
	
	
}