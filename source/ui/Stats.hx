package ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class Stats extends FlxTypedGroup<FlxObject>
{
	var scoreText:FlxText = new FlxText(0, 0, 60, "SCORE", 8);
	var scoreAmount:FlxText = new FlxText(0, 0, 60, "0", 8);
	var levelText:FlxText = new FlxText(0, 0, 60, "LEVEL", 8);
	var levelAmount:FlxText = new FlxText(0, 0, 60, "1", 8);

	public function new()
	{
		super();

		SetTextPositions();
		add(scoreText);
		add(scoreAmount);
		add(levelText);
		add(levelAmount);
	}

	function SetTextPositions()
	{
		scoreText.alignment = CENTER;
		scoreAmount.alignment = CENTER;
		levelText.alignment = CENTER;
		levelAmount.alignment = CENTER;

		scoreText.setPosition(FlxG.width - scoreText.width, (FlxG.height / 2) - 20);
		scoreAmount.setPosition(FlxG.width - scoreAmount.width, (FlxG.height / 2) - 8);
		levelText.setPosition(FlxG.width - scoreText.width, (FlxG.height / 2) + 20);
		levelAmount.setPosition(FlxG.width - scoreText.width, (FlxG.height / 2) + 32);
	}

	public function _onUpdateScore(_amount:Int)
	{
		scoreAmount.text = Std.string(_amount);
	}

	public function _onUpdateLevel(_amount:Int)
	{
		levelAmount.text = Std.string(_amount);
	}
}
