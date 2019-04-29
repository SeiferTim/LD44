package;

import axollib.AxolAPI;
import axollib.DissolveState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		//AxolAPI.gameID = "F1EF918D641A4523AC34E9B1191ECE66";
		AxolAPI.firstState = TitleState;
		AxolAPI.initialize();
		addChild(new FlxGame(320, 240, DissolveState, 2));
	}
}
