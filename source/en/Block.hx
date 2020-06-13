package en;

import com.Move.MoveCommand;
import com.Move;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import haxe.macro.Expr.Function;

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
	var isSwapping:Bool = false;

	var random:FlxRandom;
	var tween:FlxTween;
	var deathTimer:FlxTimer = new FlxTimer();

	public var fall:MoveCommand;
	public var swap:MoveCommand;

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

		swap = new MoveCommand(this);
		fall = new MoveCommand(this);
	}

	public override function update(elapsed)
	{
		if (isSwapping)
		{
			swap.Move(elapsed);
		}

		if (isFalling)
		{
			fall.Move(elapsed);
		}

		super.update(elapsed);
	}

	public function Swap(_moveDirection:Int)
	{
		col += _moveDirection;
		isSwapping = true;
		var direction:Direction = LEFT;

		switch (_moveDirection)
		{
			case -1:
				direction = LEFT;
			case 1:
				direction = RIGHT;
		}

		swap.StartMove(direction, 16, 0.2, _onSwapped.bind(_moveDirection));
	}

	public override function kill()
	{
		alive = false;

		animation.play("die");

		deathTimer.start(1, _onDeathTimerComplete);
	}

	function _onSwapped(_moveDirection:Int)
	{
		var originalCol:Int = col + (_moveDirection - (_moveDirection * 2)); // makes a negative value positive, and positive value negative
		var originalRow:Int = row;

		if (CanFall(row - 1, col))
		{
			Fall(this);
		}
		blocks.CheckForMatches(this);
		FallAboveBlocks(originalCol, originalRow);

		isSwapping = false;
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
		// trace(_blockToFall.selectedColor + " is falling");
		var fallTime:Float = 0;
		var fallDistance:Int = 1;

		blocks.RemoveBlockInGrid(_blockToFall.col, _blockToFall.row); // null out the original spot for the block so it won't be referenced here in grid

		fallTime = 0.1 * fallDistance;
		_blockToFall.row -= fallDistance;

		_blockToFall.isFalling = true;
		_blockToFall.fall.StartMove(DOWN, 16, 0.1, _onFallComplete.bind(_blockToFall));

		blocks.SetBlockInGrid(_blockToFall.col, _blockToFall.row, _blockToFall); // make reference of this block in the new fallen location
	}

	function _onFallComplete(_blockToFall:Block)
	{
		if (CanFall(_blockToFall.row - 1, _blockToFall.col))
			Fall(_blockToFall);
		else
		{
			_blockToFall.isFalling = false;
			blocks.CheckForMatches(_blockToFall);

			if (!DidBlockFallCorrectly(_blockToFall))
				// For reasons that will forever be unknown to me, at times the block will not fall all the way correctly, it will stop one spot short
				// of being correct, however the correct position will be updated on the grid.
				// This method above makes sure that it fell into the right spot and if it didn't then the block will fall one more time to fix the issue.
			{
				_blockToFall.isFalling = true;
				_blockToFall.fall.StartMove(DOWN, 16, 0.1, _onFallComplete.bind(_blockToFall));
			}
		}
	}

	function _onFallCheckTimerComplete(_timer:FlxTimer) {}

	function DidBlockFallCorrectly(_blockToFall:Block):Bool
	{
		var distance:Float = ((FlxG.height - (_blockToFall.row * 16) - blocks.currentIncrement)) - _blockToFall.y;

		if (distance > 16)
			return false;
		else
			return true;
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
				{
					// trace(blockToFall.selectedColor + (" will fall!"));
					Fall(blockToFall);
				}

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
