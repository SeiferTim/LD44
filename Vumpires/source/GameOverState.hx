package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;

class GameOverState extends FlxTransitionableState
{

	private var elements:Array<FlxSprite>;

	static var actions:FlxActionManager;

	public var jump:FlxActionDigital;
	public var swing:FlxActionDigital;
	public var ball:FlxActionDigital;

	private var leaving:Bool = false;
	
	private var a:FlxBitmapText;
	
	private var isGameOver:Bool = false;

	public function new(?GameOver:Bool = true)
	{
		super();
		isGameOver = GameOver;
	}
	
	override public function create():Void
	{

		super.create();

		
		
		
		
		elements = [];

		var t:FlxBitmapText = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		if (isGameOver)
		{
			t.text = "YOU'RE OUT!";
			FlxG.sound.play(AssetPaths.GameOver__wav);
		}
		else
		{
			t.text = "YOU ARE THE MVP!";
			FlxG.sound.play(AssetPaths.win__wav);
		}
		
		t.screenCenter();
		elements.push(t);
		add(t);

		var b:FlxSprite = new FlxSprite(4, 4, AssetPaths.Ball__png);
		elements.push(b);
		add(b);
		b = new FlxSprite(4, FlxG.height - b.height - 4, AssetPaths.Ball__png);
		elements.push(b);
		add(b);
		b = new FlxSprite(FlxG.width - b.height - 4, FlxG.height - b.height - 4, AssetPaths.Ball__png);
		elements.push(b);
		add(b);
		b = new FlxSprite(FlxG.width - b.height -4, 4, AssetPaths.Ball__png);
		elements.push(b);
		add(b);

		for (i in elements)
		{
			i.alpha = 0;
			FlxTween.tween(i, {alpha:1}, .33, {ease:FlxEase.cubeIn, type:FlxTweenType.ONESHOT, startDelay:.2});
		}

		a  = new FlxBitmapText(FlxBitmapFont.fromAngelCode(AssetPaths.story_text__png, AssetPaths.story_text__xml));
		a.text = "Press any Key to Play Again";
		a.screenCenter(FlxAxes.X);
		a.y = FlxG.height - a.height - 8;
		a.alpha = 0;
		add(a);

		FlxTween.tween(a, {alpha:1}, .33, {ease:FlxEase.cubeIn, type:FlxTweenType.ONESHOT, startDelay:.66});
		
		
		jump = new FlxActionDigital();
		swing = new FlxActionDigital();
		ball = new FlxActionDigital();
		
		if (actions == null)
		{
			actions = FlxG.inputs.add(new FlxActionManager());
		}
		
		actions.addActions([jump, swing, ball]);
		
		jump.addKey(X, PRESSED);
		jump.addKey(SPACE, PRESSED);
		jump.addGamepad(A, PRESSED);
		jump.addGamepad(B, PRESSED);
		swing.addKey(Z, PRESSED);
		swing.addGamepad(X, PRESSED);
		ball.addKey(C, PRESSED);
		ball.addGamepad(Y, PRESSED);
		
		

	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (a.alpha >= 1 && !leaving )
		{
			if (jump.triggered || ball.triggered || swing.triggered)
			{
				leaving = true;
				FlxG.inputs.remove(actions);
				FlxG.sound.play(AssetPaths.possiblestartsound__wav, 1, false, null, true, function() {
					FlxG.sound.play(AssetPaths.play_ball__wav);
					FlxFlicker.flicker(a, 1, .25, true, true, function(_) {				
						FlxG.camera.flash(0xffac3232, .2, function() {
							FlxG.switchState(new PlayState());
						});
					});
				});
			}
		}
	}

}