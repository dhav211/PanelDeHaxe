package en;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Blocks extends FlxTypedGroup<Block>
{
	public var grid:Array<Array<Block>> = [];

	final GRID_WIDTH:Int = 6;
	final GRID_HEIGHT:Int = 14;

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
		grid = CreateEmptyGrid();
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

	public function CheckForMatches(_originBlock:Block)
	{
		var horizonalMatches:Array<Block> = [];
		var verticalMatches:Array<Block> = [];

		for (i in 0...4)
		{
			if (i == 0) // Check Up
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, 1);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 1) // Check Down
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 0, -1);
				while (matches.length > 0)
					verticalMatches.push(matches.pop());
			}

			if (i == 2) // Check Right
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, 1, 0);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}

			if (i == 3) // Check Left
			{
				var matches:Array<Block> = CheckInDirectionForMatches(_originBlock, -1, 0);
				while (matches.length > 0)
					horizonalMatches.push(matches.pop());
			}
		}

		if (verticalMatches.length > 1 || horizonalMatches.length > 1)
		{
			_originBlock.color = FlxColor.GRAY;

			for (match in verticalMatches)
			{
				match.color = FlxColor.GRAY;
			}

			for (match in horizonalMatches)
			{
				match.color = FlxColor.GRAY;
			}
		}
	}

	function CheckInDirectionForMatches(_originBlock:Block, _colDirection:Int, _rowDirection):Array<Block>
	{
		var distanceToCheck = 1;
		var isCheckingForMatches = true;
		var blocksFound:Array<Block> = [];

		while (isCheckingForMatches)
		{
			var blockToCheck:Block = null;
			if (IsInGridBounds(_originBlock, _colDirection, _rowDirection, distanceToCheck)
				&& grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)] != null)
				blockToCheck = grid[_originBlock.col + (distanceToCheck * _colDirection)][_originBlock.row + (distanceToCheck * _rowDirection)];

			if (blockToCheck != null && blockToCheck.selectedColor == _originBlock.selectedColor)
			{
				blocksFound.push(blockToCheck);
				distanceToCheck++;
			}
			else if (blockToCheck == null || blockToCheck.selectedColor != _originBlock.selectedColor)
			{
				isCheckingForMatches = false;
			}
		}

		return blocksFound;
	}

	function IsInGridBounds(_originBlock:Block, _colDirection:Int, _rowDirection, _distanceToCheck):Bool
	{
		if (_originBlock.col + (_distanceToCheck * _colDirection) >= GRID_WIDTH)
			return false;
		if (_originBlock.col + (_distanceToCheck * _colDirection) < 0)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) > GRID_HEIGHT)
			return false;
		if (_originBlock.row + (_distanceToCheck * _rowDirection) <= 0)
			return false;

		return true;
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
			var block:Block = new Block(xStartingPosition + (16 * i), yPosition, 0, i, random, this);
			grid[i][0] = block;
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
				var block:Block = new Block(xStartingPosition + (16 * i), yStartingPosition - (16 * j), j, i, random, this);
				grid[i][j] = block;
				add(block);
			}
		}
	}

	function CreateEmptyGrid():Array<Array<Block>>
	{
		var emptyBlock:Block = null;
		var tempGrid:Array<Array<Block>> = [for (x in 0...GRID_WIDTH) [for (y in 0...GRID_HEIGHT) emptyBlock]];
		return tempGrid;
	}
}
