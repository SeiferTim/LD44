package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class MovieState extends FlxTransitionableState
{

	private var scene_01:FlxSprite;
	private var scene_02:FlxSprite;
	private var scene_03:FlxSprite;
	private var scene_04:FlxSprite;
	private var text_01:FlxBitmapText;
	private var text_02:FlxBitmapText;
	private var text_03:FlxBitmapText;
	private var text_04:FlxBitmapText;
	private var text_05:FlxBitmapText;
	private var blackout_top:FlxSprite;
	private var blackout_bottom:FlxSprite;
	private var whiteout:FlxSprite;
	
	static var actions:FlxActionManager;
	
	public var jump:FlxActionDigital;
	public var swing:FlxActionDigital;
	public var b:FlxActionDigital;
	
	private var txtSkip:FlxSprite;
	private var bar:FlxBar;
	private var skipTimer:Float = 0;
	private var leaving:Bool = false;

	override public function create():Void
	{
		super.create();

		scene_01 = new FlxSprite(0, 0, AssetPaths.screen_01__png);
		scene_02 = new FlxSprite(0, 0, AssetPaths.screen_02__png);
		scene_03 = new FlxSprite(0, 0, AssetPaths.screen_03__png);
		scene_04 = new FlxSprite(0, 0, AssetPaths.screen_04__png);

		scene_01.screenCenter(FlxAxes.X);
		scene_01.y = 8;

		scene_04.x = scene_02.x = scene_03.x = scene_01.x;
		scene_04.y = scene_02.y = scene_03.y = scene_01.y;

		blackout_top = new FlxSprite();
		blackout_top.makeGraphic(FlxG.width, Std.int(scene_01.height + 16), FlxColor.BLACK);
		
		blackout_bottom = new FlxSprite();
		blackout_bottom.makeGraphic(FlxG.width, 8, FlxColor.BLACK);
		blackout_bottom.y = FlxG.height - 8;
		
		scene_01.alpha = scene_02.alpha = scene_03.alpha = scene_04.alpha = 0;
		
		text_01 = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		text_02 = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		text_03 = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		text_04 = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		text_05 = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		
		text_05.y = text_01.y = text_02.y = text_03.y = text_04.y = FlxG.height;
		text_05.multiLine = text_01.multiLine = text_02.multiLine = text_03.multiLine = text_04.multiLine = true;
		text_05.alignment = text_01.alignment = text_02.alignment = text_03.alignment = text_04.alignment = FlxTextAlign.CENTER;
		text_05.autoSize = text_01.autoSize = text_02.autoSize = text_03.autoSize = text_04.autoSize = false;
		text_05.fieldWidth = text_01.fieldWidth = text_02.fieldWidth = text_03.fieldWidth = text_04.fieldWidth = FlxG.width - 16;
		
		text_01.text = "Legend tells of an ancient curse: every 5000 years...";
		text_02.text = "...when the moon and stars come into perfect alignment on the evening of Opening Day;";
		text_03.text = "A great, evil, power surges from the cosmos!";
		text_04.text = "A power that corrupts everyone it touches into crazed, bloodthirsty, monsters!";
		text_05.text = "It is the time of the Vumpire!";
		
		text_01.screenCenter(FlxAxes.X);
		text_02.screenCenter(FlxAxes.X);
		text_03.screenCenter(FlxAxes.X);
		text_04.screenCenter(FlxAxes.X);
		text_05.screenCenter(FlxAxes.X);
		
		add(text_01);
		add(text_02);
		add(text_03);
		add(text_04);
		add(text_05);
		
		add(blackout_top);
		add(blackout_bottom);
		
		txtSkip = new FlxSprite(0, 0, AssetPaths.skip__png);
		txtSkip.x = FlxG.width - txtSkip.width - 4;
		txtSkip.y = FlxG.height - txtSkip.height - 4;
		txtSkip.visible = false;
		
		bar = new FlxBar(txtSkip.x -1, txtSkip.y -1, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(txtSkip.width) + 2, Std.int(txtSkip.height) + 2, this, "skipTimer", 0, 3, false);
		bar.createFilledBar(0x0, 0xff5fcde4);
		
		add(bar);
		add(txtSkip);
		
		add(scene_01);
		add(scene_02);
		add(scene_03);
		add(scene_04);
		
		whiteout = new FlxSprite();
		whiteout.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteout.alpha = 0;
		add(whiteout);
		
		#if flash
		FlxG.sound.playMusic(AssetPaths.Movie__mp3, 1, false);
		#else
		FlxG.sound.playMusic(AssetPaths.Movie__ogg, 1, false);
		#end
		
		jump = new FlxActionDigital();
		swing = new FlxActionDigital();
		b = new FlxActionDigital();
		
		if (actions == null)
		{
			actions = FlxG.inputs.add(new FlxActionManager());
		}
		
		actions.addActions([jump, swing, b]);
		
		jump.addKey(X, PRESSED);
		jump.addKey(SPACE, PRESSED);
		jump.addGamepad(A, PRESSED);
		jump.addGamepad(B, PRESSED);
		swing.addKey(Z, PRESSED);
		swing.addGamepad(X, PRESSED);
		b.addKey(C, PRESSED);
		b.addGamepad(Y, PRESSED);
		
		FlxTween.tween(scene_01, {alpha:1}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:2});
		
		FlxTween.linearMotion(text_01, text_01.x, text_01.y, text_01.x, blackout_top.y + blackout_top.height - text_01.height, 11, false, {onComplete: function(_) {
			FlxTween.tween(scene_01, {alpha:0}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1.5});	
			FlxTween.tween(scene_02, {alpha:1}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:2});
			FlxTween.linearMotion(text_02, text_02.x, text_02.y, text_02.x, blackout_top.y + blackout_top.height - text_02.height, 11, false, {onComplete: function(_) {
				FlxTween.tween(scene_02, {alpha:0}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1.5});	
				FlxTween.tween(scene_03, {alpha:1}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:2});
				FlxTween.linearMotion(text_03, text_03.x, text_03.y, text_03.x, blackout_top.y + blackout_top.height - text_03.height, 11, false, {onComplete: function(_) {
					FlxTween.tween(scene_03, {alpha:0}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1.5});	
					FlxTween.tween(scene_04, {alpha:1}, 1, {type:FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:2});	
					FlxTween.linearMotion(text_04, text_04.x, text_04.y, text_04.x, blackout_top.y + blackout_top.height - text_04.height, 11, false, {onComplete: function(_) {
						FlxTween.linearMotion(text_05, text_05.x, text_05.y, text_05.x, blackout_top.y + blackout_top.height + 8, 11, false, {onComplete: function(_) {
							FlxG.sound.play(AssetPaths.FlashSound__wav);	
							FlxG.camera.flash(FlxColor.WHITE, .1, function() {
								FlxG.sound.play(AssetPaths.FlashSound__wav);
								whiteout.alpha = 1;
								FlxTween.tween(whiteout, {alpha:0}, 1,{ease:FlxEase.quadOut,type:FlxTweenType.ONESHOT,onComplete: function(_){
									leaving = true;
									FlxG.inputs.remove(actions);
									FlxG.switchState(new PlayState());
								}});
							});
						}});
					}});
				}});
			}});
		}, startDelay:.4});
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		if (!leaving)
		{
			if (jump.triggered || b.triggered || swing.triggered)
			{
				skipTimer += elapsed;
				if (skipTimer > 3)
				{
					leaving = true;
					FlxG.inputs.remove(actions);
					FlxG.switchState(new PlayState());
				}
			}
			else if (skipTimer > 0)
				skipTimer -= elapsed;
				
			txtSkip.visible = skipTimer > 0;
				
		}
		
		
		super.update(elapsed);
	}

	
	override public function destroy():Void 
	{
		
		scene_01 = FlxDestroyUtil.destroy(scene_01);
		scene_02 = FlxDestroyUtil.destroy(scene_02);
		scene_03 = FlxDestroyUtil.destroy(scene_03);
		scene_04 = FlxDestroyUtil.destroy(scene_04);
		text_01 = FlxDestroyUtil.destroy(text_01);
		text_02 = FlxDestroyUtil.destroy(text_02);
		text_03 = FlxDestroyUtil.destroy(text_03);
		text_04 = FlxDestroyUtil.destroy(text_04);
		text_05 = FlxDestroyUtil.destroy(text_05);
		blackout_top = FlxDestroyUtil.destroy(blackout_top);
		blackout_bottom = FlxDestroyUtil.destroy(blackout_bottom);
		whiteout = FlxDestroyUtil.destroy(whiteout);

		actions = FlxDestroyUtil.destroy(actions);

		jump = FlxDestroyUtil.destroy(jump);
		swing = FlxDestroyUtil.destroy(swing);
		b = FlxDestroyUtil.destroy(b);

		txtSkip = FlxDestroyUtil.destroy(txtSkip);
		bar = FlxDestroyUtil.destroy(bar);
		
		super.destroy();
	}
	
}