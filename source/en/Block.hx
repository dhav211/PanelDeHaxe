package en;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

enum Color
{
	BLUE;
	GREEN;
	PURPLE;
	RED;
	TEAL;
	YELLOW;
}

class Block extends FlxSprite
{
	public var row:Int = 0;
	public var col:Int = 0;
	public var selectedColor:Color;

	var blocks:Blocks;
	var fallSpeed:Float = 50;
	var isFalling:Bool = false;

	var random:FlxRandom;
	var tween:FlxTween;
	var deathTimer:FlxTimer = new FlxTimer();

	public function new(x:Float, y:Float, _row:Int, _col:Int, _random:FlxRandom, _blocks:Blocks)
	{
		super(x, y);

		random = _random;
		blocks = _blocks;
		row = _row;
		col = _col;

		selectedColor = SetColor();
		loadGraphic(LoadGraphicBasedOnSelectedColor(), true, 16, 16);

		animation.add("still", [0], 8, true);
		animation.add("die", [0, 5, 0, 5, 0, 5, 0, 5, 6], 8, false);
		animation.play("still");
	}

	public function Swap(_moveDirection:Int)
	{
		col += _moveDirection;

		tween = FlxTween.tween(this, {x: x + (_moveDirection * 16)}, 0.2,
			{onComplete: _onSwapped.bind(_, _moveDirection)}); // underscore is used for function binding
	}

	public override function kill()
	{
		alive = false;

		animation.play("die");

		deathTimer.start(1, _onDeathTimerComplete);
	}

	function _onSwapped(_tween:FlxTween, _moveDirection:Int)
	{
		var originalCol:Int = col + (_moveDirection - (_moveDirection * 2)); // makes a negative value positive, and positive value negative
		var originalRow:Int = row;

		if (CanFall(row - 1, col))
		{
			Fall(this);
		}
		blocks.CheckForMatches(this);
		FallAboveBlocks(originalCol, originalRow);
	}

	function _onDeathTimerComplete(timer:FlxTimer)
	{
		blocks.RemoveBlockInGrid(col, row);

		if (blocks.grid[col][row + 1] != null && blocks.grid[col][row + 1].alive)
		{
			FallAboveBlocks(col, row);
		}

		destroy();
	}

	function CanFall(_rowToFall:Int, _colToCheck:Int):Bool
	{
		if (blocks.grid[_colToCheck][_rowToFall] != null)
			return false;
		else
			return true;
	}

	function Fall(_blockToFall:Block)
	{
		var fallTime:Float = 0;
		var fallDistance:Int = 1;

		blocks.RemoveBlockInGrid(_blockToFall.col, _blockToFall.row); // null out the original spot for the block so it won't be referenced here in grid

		fallTime = 0.1 * fallDistance;
		_blockToFall.row -= fallDistance;

		_blockToFall.tween = FlxTween.tween(_blockToFall, {y: _blockToFall.y + (fallDistance * 16)}, fallTime,
			{onComplete: _onFallComplete.bind(_, _blockToFall)});
		blocks.SetBlockInGrid(_blockToFall.col, _blockToFall.row, _blockToFall); // make reference of this block in the new fallen location
	}

	function _onFallComplete(_tween:FlxTween, _blockToFall:Block)
	{
		if (CanFall(_blockToFall.row - 1, _blockToFall.col))
			Fall(_blockToFall);
		else
		{
			blocks.CheckForMatches(_blockToFall);

			if (_blockToFall.y != FlxG.height - (_blockToFall.row * 16)) // In case the block was not tweened correctly, this will do it once more
			{
				_blockToFall.tween = FlxTween.tween(_blockToFall, {y: _blockToFall.y + 16}, 0.1);
			}
		}
	}

	public function FallAboveBlocks(_originalCol:Int, _originalRow:Int)
	{
		var rowToCheck:Int = _originalRow + 1;
		var isSearchingForHigherBlocks:Bool = true;

		while (isSearchingForHigherBlocks)
		{
			if (blocks.grid[_originalCol][rowToCheck] != null
				&& blocks.grid[_originalCol][rowToCheck].alive) // There is a block above so check to see if it can fall
			{
				var blockToFall:Block = blocks.grid[_originalCol][rowToCheck];

				if (CanFall(rowToCheck - 1, _originalCol))
					Fall(blockToFall);

				rowToCheck++; // check to see if there is a block above
			}
			else if (blocks.grid[_originalCol][rowToCheck] == null
				|| !blocks.grid[_originalCol][rowToCheck].alive) // No more blocks above, so stop the loop
			{
				isSearchingForHigherBlocks = false;
			}
		}
	}

	function SetColor():Color
	{
		// choose a random number the in the range of Color enums, use number chosen to get color
		var randomChoice:Int = random.int(0, 6);

		switch (randomChoice)
		{
			case 0:
				return BLUE;
			case 1:
				return GREEN;
			case 2:
				return PURPLE;
			case 3:
				return RED;
			case 4:
				return TEAL;
			case 5:
				return YELLOW;
			case _:
				return BLUE;
		}
	}

	function LoadGraphicBasedOnSelectedColor():String
	{
		switch (selectedColor)
		{
			case BLUE:
				return AssetPaths.blue_blocks__png;
			case GREEN:
				return AssetPaths.green_blocks__png;
			case PURPLE:
				return AssetPaths.purple_blocks__png;
			case RED:
				return AssetPaths.red_blocks__png;
			case TEAL:
				return AssetPaths.teal_blocks__png;
			case YELLOW:
				return AssetPaths.yellow_blocks__png;
		}
	}
}
