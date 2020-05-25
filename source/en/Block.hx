package en;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;

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

	var blocks:FlxTypedGroup<Block>;
	var fallSpeed:Float = 50;
	var isFalling:Bool = false;

	var random:FlxRandom;
	var tween:FlxTween;

	public function new(x:Float, y:Float, _row:Int, _col:Int, _random:FlxRandom, _blocks:FlxTypedGroup<Block>)
	{
		super(x, y);

		solid = true;

		random = _random;
		blocks = _blocks;
		row = _row;
		col = _col;

		selectedColor = SetColor();
		loadGraphic(LoadGraphicBasedOnSelectedColor(), true, 16, 16);

		animation.add("still", [0], 8, true);
		animation.play("still");
	}

	public function Swap(_moveDirection:Int)
	{
		col += _moveDirection;
		solid = false;
		tween = FlxTween.tween(this, {x: x + (_moveDirection * 16)}, 0.2,
			{onComplete: _onSwapped.bind(_, _moveDirection)}); // underscore is used for function binding
	}

	function _onSwapped(_tween:FlxTween, _moveDirection:Int)
	{
		solid = true;

		if (CanFall(row - 1, col))
		{
			Fall();
		}

		FallAboveBlocks(_moveDirection);
	}

	function CanFall(_rowToFall:Int, _colToCheck:Int):Bool
	{
		for (block in blocks)
		{
			if (block.col == _colToCheck && block.row == _rowToFall)
			{
				return false;
			}
		}

		return true;
	}

	function Fall()
	{
		var rowToFall:Int = row - 1;
		var fallTime:Float = 0;
		var fallDistance:Int = 0;
		var hasFoundRowToFall = false;

		while (!hasFoundRowToFall)
		{
			if (CanFall(rowToFall, col))
			{
				rowToFall--;
				fallDistance++;
			}
			else
			{
				hasFoundRowToFall = true;
			}
		}

		fallTime = 0.1 * fallDistance;
		row -= fallDistance;
		tween = FlxTween.tween(this, {y: y + (fallDistance * 16)}, fallTime);
	}

	function FallAboveBlocks(_moveDirection:Int)
	{
		var colToCheck:Int = _moveDirection - (_moveDirection * 2); // makes a negative value positive, and positive value negative
		colToCheck += col; // This will actually get the column to check
		var rowToCheck:Int = row + 1;
		var dropDistance:Int = 1;
		var isSearchingForHigherBlocks:Bool = true;

		while (isSearchingForHigherBlocks)
		{
			for (block in blocks)
			{
				if (block.row == rowToCheck && block.col == colToCheck) // There is a block above so check to see if it can fall
				{
					if (CanFall(rowToCheck - 1, colToCheck))
					{
						tween = FlxTween.tween(block, {y: block.y + 16}, 0.1);
						block.row--;
						dropDistance++;
					}
					rowToCheck++;
				}
				else if (block.row != rowToCheck && block.col == colToCheck)
				{
					isSearchingForHigherBlocks = false;
				}
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
