package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class ScoreboardText extends FlxBitmapText 
{

	public function new(Text:String = "") 
	{
		super(FlxBitmapFont.fromAngelCode(AssetPaths.font__png, AssetPaths.font__xml));
		text = Text;
		scrollFactor.set();
	}
	
}