package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class TitleState extends FlxTransitionableState 
{

	private var v:FlxSprite;
	private var umpire:FlxSprite;
	private var ball:FlxSprite;
	private var fBall:FlxSprite;
	private var line:FlxSprite;
	private var sub:FlxSprite;
	private var axol:FlxSprite;
	private var play:FlxSprite;
	private var mini1:FlxSprite;
	private var mini2:FlxSprite;
	
	static var actions:FlxActionManager;
	
	public var jump:FlxActionDigital;
	public var swing:FlxActionDigital;
	public var b:FlxActionDigital;
	
	private var leaving:Bool = false;
	
	
	
	override public function create():Void 
	{
		
		super.create();
		
		#if flash
		FlxG.sound.playMusic(AssetPaths.Title__mp3);
		#else
		FlxG.sound.playMusic(AssetPaths.Title__ogg);
		#end
		
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileCircle);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		var t:TransitionData = new TransitionData(TransitionType.TILES);
		t.tileData = {asset: diamond, width: 32, height: 32};
		FlxTransitionableState.defaultTransIn = t;
		
		//var t:TransitionData = new TransitionData();
		//t.tileData = {asset: diamond, width: 32, height: 32};
		FlxTransitionableState.defaultTransOut = t;
		transOut = t;
		
		bgColor = FlxColor.BLACK;
		
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
		
		
		
		ball = new FlxSprite(0, 0, AssetPaths.title_ball__png);
		fBall = new FlxSprite(0, 0, AssetPaths.title_ball_f__png);
		umpire = new FlxSprite(0, 0, AssetPaths.title_umpires__png);
		line = new FlxSprite(0, 0, AssetPaths.title_line__png);
		sub = new FlxSprite(0, 0, AssetPaths.title_subtitle__png);
		v = new FlxSprite(0, 0, AssetPaths.title_v__png);
		axol = new FlxSprite(0, 0, AssetPaths.title_axol__png);
		play = new FlxSprite(0, 0, AssetPaths.title_play_ball__png);
		mini1 = new FlxSprite();
		mini2 = new FlxSprite();
		
		mini1.loadRotatedGraphic(AssetPaths.title_ball_mini__png, 360,-1, false, true, "mini-ball");
		mini2.loadRotatedGraphic(AssetPaths.title_ball_mini__png, 360,-1, false, true, "mini-ball");
		
		
		ball.screenCenter();
		fBall.screenCenter();
		
		
		ball.y = fBall.y += 20;
		
		axol.x = FlxG.width - axol.width - 4;
		axol.y = FlxG.height - axol.height - 4;
		
		play.screenCenter(FlxAxes.X);
		play.y = (FlxG.height * .88 ) - (play.height / 2);
		
		mini1.x = play.x - mini1.width - 6;
		mini1.y = play.y + (play.height / 2) - (mini1.height / 2);
		mini1.angularVelocity = 200;
		
		mini2.x = play.x + play.width + 6;
		mini2.y = play.y + (play.height / 2) - (mini2.height / 2);
		mini2.angularVelocity = -200;
		
		add(ball);
		add(fBall);
		add(umpire);
		add(line);
		add(sub);
		add(v);
		add(axol);
		add(play);
		add(mini1);
		add(mini2);
		
	
		ball.alpha = fBall.alpha = umpire.alpha = line.alpha = sub.alpha = v.alpha = axol.alpha = play.alpha = mini1.alpha = mini2.alpha = 0;
		
		v.scale.x = v.scale.y = ball.scale.x = ball.scale.y = 3;
		
		FlxTween.tween(ball.scale, {x: 1, y: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:.33});
		FlxTween.tween(ball, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:.33, onComplete: function(_) {
			FlxG.camera.flash(0xffac3232, .2);
		}});
		
		FlxTween.tween(v.scale, {x: 1, y: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:.5});
		FlxTween.tween(v, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:.5});
		
		
		FlxTween.tween(umpire, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1});
		FlxTween.tween(line, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1.4});
		FlxTween.tween(sub, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:1.8});
		FlxTween.tween(axol, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:2.2, onComplete: function(_) {
			fBall.alpha = 1;
			FlxG.camera.flash(0xffac3232, .2);
		}});
		
		FlxTween.tween(play, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:3});
		FlxTween.tween(mini1, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:3});
		FlxTween.tween(mini2, {alpha: 1}, .33, {type: FlxTweenType.ONESHOT, ease:FlxEase.cubeIn, startDelay:3});
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (play.alpha >= 1 && !leaving )
		{
			if (jump.triggered || b.triggered || swing.triggered)
			{
				leaving = true;
				FlxG.inputs.remove(actions);
				FlxG.sound.play(AssetPaths.possiblestartsound__wav, 1, false, null, true, function() {
					FlxG.sound.play(AssetPaths.play_ball__wav);
					FlxFlicker.flicker(play, 1, .25, true, true, function(_) {				
						FlxG.camera.flash(0xffac3232, .2, function() {
							FlxG.switchState(new MovieState());
						});
					});
				});
			}
		}
		
	}
	
	
	override public function destroy():Void 
	{
		
		v = FlxDestroyUtil.destroy(v);
		umpire = FlxDestroyUtil.destroy(umpire);
		ball = FlxDestroyUtil.destroy(ball);
		fBall = FlxDestroyUtil.destroy(fBall);
		line = FlxDestroyUtil.destroy(line);
		sub = FlxDestroyUtil.destroy(sub);
		axol = FlxDestroyUtil.destroy(axol);
		play = FlxDestroyUtil.destroy(play);
		mini1 = FlxDestroyUtil.destroy(mini1);
		mini2 = FlxDestroyUtil.destroy(mini2);
		actions = FlxDestroyUtil.destroy(actions);
		jump = FlxDestroyUtil.destroy(jump);
		swing = FlxDestroyUtil.destroy(swing);
		b = FlxDestroyUtil.destroy(b);
		
		
		super.destroy();
	}
}