package en;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

enum CheckDirection
{
	HORIZONTAL;
	VERTICAL;
}

class Blocks extends FlxTypedGroup<Block>
{
	var speed:Float = 10;

	var currentIncrement:Int = 0;
	final MAX_INCREMENT:Int = 4;

	var timer:FlxTimer = new FlxTimer();
	var tween:FlxTween;
	var random:FlxRandom;

	public function new(_random:FlxRandom)
	{
		super();

		random = _random;
		// timer.start(60 / speed);
	}

	public override function update(elapsed:Float)
	{
		if (timer.finished)
		{
			MoveBlocksUp();
			timer.start(60 / speed);

			currentIncrement++;
			if (currentIncrement == MAX_INCREMENT)
			{
				IncreaseBlocksRowCount();
				SpawnRow();
				currentIncrement = 0;
			}
		}

		super.update(elapsed);
	}

	public function CheckForMatches(_blockToCheck:Block)
	{
		var isCheckingForMatches:Bool = true;
		var foundBlocks:Array<Block> = [];
		var matchedBlocks:Array<Block> = [];

		while (isCheckingForMatches)
		{
			if (_blockToCheck == null)
				_blockToCheck = foundBlocks.shift();
			// Check all four directions on _blockToCheck
		}
	}

	function MoveBlocksUp()
	{
		for (block in this)
		{
			tween = FlxTween.tween(block, {x: block.x, y: block.y - 4}, 0.2);
		}
	}

	function IncreaseBlocksRowCount()
	{
		for (block in this)
		{
			block.row++;
		}
	}

	public function SpawnRow()
	{
		var yPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;

		for (i in 0...6)
		{
			var block:Block = new Block(xStartingPosition + (16 * i), yPosition, 1, i + 1, random, this);
			add(block);
		}
	}

	public function SpawnInitalBlocks()
	{
		var random:FlxRandom = new FlxRandom();
		var yStartingPosition:Float = FlxG.height;
		var xStartingPosition:Float = 16;

		for (i in 0...6)
		{
			var rowHeight:Int = random.int(4, 8);

			for (j in 0...rowHeight)
			{
				var block:Block = new Block(xStartingPosition + (16 * i), yStartingPosition - (16 * j), j + 1, i + 1, random, this);
				add(block);
			}
		}
	}
}
