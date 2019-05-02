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
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.io.Path;

class TiledLevel extends TiledMap implements IFlxDestroyable
{
	public var coll:FlxTilemapExt;
	public var wallsLayer:FlxGroup;
	public var background:FlxGroup;
	private var collidableTileLayers:Array<FlxTilemap>;
	public var playerStart:FlxPoint;
	public var enemies:Array<FlxSprite>;

	public function new(data:FlxTiledMapAsset, ?rootPath:String)
	{
		super(data, rootPath);

		wallsLayer = new FlxGroup();
		background = new FlxGroup();
		playerStart = FlxPoint.get();
		enemies = new Array<FlxSprite>();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		var t:TiledTileLayer = cast layerMap.get("walls");

		var tS:TiledTileSet = tilesets.get("tmp-tiles");

		var tileMap:FlxTilemapExt = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + "../images/temp-tiles.png"), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);

		for (tileProp in tS.tileProps)
		{
			if (tileProp != null)
			{
				if (tileProp.keys.exists("cloud"))
				{
					if (tileProp.get("cloud") == "true")
					{

						if (tileProp.tileID == 52)
						{

						}
						else if (tileProp.tileID == 53)
						{

						}
						else
							tileMap.setTileProperties(tS.toGid(tileProp.tileID), FlxObject.UP);
					}
				}
			}
		}

		tileMap.setSlopes([tS.toGid(52)], [tS.toGid(53)]);

		collidableTileLayers = new Array<FlxTilemap>();
		collidableTileLayers.push(tileMap);
		coll = tileMap;

		wallsLayer.add(tileMap);

		t = cast layerMap.get("background");
		tileMap = new FlxTilemapExt();
		tileMap.loadMapFromArray(t.tileArray, width, height, Path.normalize(rootPath + "../images/temp-tiles.png"), tS.tileWidth, tS.tileHeight, OFF, tS.firstGID, 1, 1);
		background.add(tileMap);

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
					v.facing = j.flippedHorizontally ? FlxObject.RIGHT : FlxObject.LEFT;
					enemies.push(v);
				case "enemy_2":
					var b:BallBat = new BallBat();
					b.x = j.x + (j.width/2);
					b.y = j.y - j.height + (j.height / 2);
					b.facing = j.flippedHorizontally ? FlxObject.RIGHT : FlxObject.LEFT;
					enemies.push(b);
				case "enemy_3":
					var s:StandVump = new StandVump();
					s.x = j.x + (j.width/2);
					s.y = j.y;
					s.facing = j.flippedHorizontally ? FlxObject.RIGHT : FlxObject.LEFT;
					enemies.push(s);
				default:

			}

		}

	}

	public function collideWithLevel(obj:FlxBasic):Bool
	{
		for (map in collidableTileLayers)
		{
			FlxG.collide(coll, obj);
		}
		return false;
	}

	public function destroy():Void
	{
		coll = FlxDestroyUtil.destroy(coll);
		wallsLayer = FlxDestroyUtil.destroy(wallsLayer);
		background = FlxDestroyUtil.destroy(background);
		collidableTileLayers = FlxDestroyUtil.destroyArray(collidableTileLayers);
		playerStart = FlxDestroyUtil.destroy(playerStart);
		enemies = FlxDestroyUtil.destroyArray(enemies);
	}

}