package en;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Cursor extends FlxSprite
{
	public var row:Int = 0;
	public var colLeft:Int = 0;
	public var colRight:Int = 0;

	var xPosModifier:Float = 2;
	var yPosModifier:Float = 2;

	var canPress:Bool = true;

	var blocks:Blocks;
	var tween:FlxTween;

	public function new(x:Float, y:Float, _blocks:Blocks)
	{
		super(x, y);
		blocks = _blocks;
		loadGraphic(AssetPaths.cursor__png, false, 16, 16);
		SetInitalPosition();

		tween = FlxTween.tween(this, {x: x, y: y}, 0);
	}

	public override function update(elapsed:Float)
	{
		Move();
		SwapBlocks();
		GetBlockColors();
	}

	function GetBlockColors() // Debug
	{
		if (FlxG.keys.anyJustPressed([C]) && canPress)
		{
			canPress = false;

			if (blocks.grid[colLeft][row] != null)
				trace("Left: " + blocks.grid[colLeft][row].selectedColor + " at " + colLeft + " - " + row);
			else
				trace("Left: NULL " + " at " + colLeft + " - " + row);

			if (blocks.grid[colRight][row] != null)
				trace("Right: " + blocks.grid[colRight][row].selectedColor + " at " + colRight + " - " + row);
			else
				trace("Right: NULL " + " at " + colRight + " - " + row);
		}

		if (FlxG.keys.anyJustReleased([C]) && !canPress)
			canPress = true;
	}

	function Move()
	{
		var left:Bool = FlxG.keys.anyPressed([LEFT]);
		var right:Bool = FlxG.keys.anyPressed([RIGHT]);
		var up:Bool = FlxG.keys.anyPressed([UP]);
		var down:Bool = FlxG.keys.anyPressed([DOWN]);

		if (!tween.active)
		{
			// Cancel any undesired movements
			if (left && right)
				left = right = false;
			if (up && down)
				up = down = false;
			if (left && up)
				left = up = false;
			if (left && down)
				left = down = false;
			if (right && up)
				right = up = false;
			if (right && down)
				right = down = false;

			if (left && CanMove(left))
			{
				tween = FlxTween.tween(this, {x: x - 16}, 0.2);
				colLeft--;
				colRight--;
			}

			if (right && CanMove(right))
			{
				tween = FlxTween.tween(this, {x: x + 16}, 0.2);
				colLeft++;
				colRight++;
			}

			if (down && CanMove(down))
			{
				tween = FlxTween.tween(this, {y: y + 16}, 0.2);
				row--;
			}

			if (up && CanMove(up))
			{
				tween = FlxTween.tween(this, {y: y - 16}, 0.2);
				row++;
			}
		}
	}

	function CanMove(_directionPressed:Bool):Bool // Checks if it's in bounds to move in the given direction
	{
		if (_directionPressed == FlxG.keys.anyPressed([LEFT]))
			if (colLeft > 0)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([RIGHT]))
			if (colRight < 5)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([DOWN]))
			if (row > 1)
				return true;

		if (_directionPressed == FlxG.keys.anyPressed([UP]))
		{
			if (row < 13)
				return true;
		}

		return false;
	}

	function SwapBlocks()
	{
		var pressed:Bool = FlxG.keys.anyJustPressed([SPACE]);
		var released:Bool = FlxG.keys.anyJustReleased([SPACE]);
		var leftBlock:Block = null;
		var rightBlock:Block = null;

		if (pressed && canPress)
		{
			leftBlock = blocks.grid[colLeft][row];
			rightBlock = blocks.grid[colRight][row];

			if (leftBlock != null)
			{
				leftBlock.Swap(1);
				blocks.grid[colRight][row] = leftBlock;
			}
			else
			{
				blocks.grid[colRight][row] = null;
			}

			if (rightBlock != null)
			{
				rightBlock.Swap(-1);
				blocks.grid[colLeft][row] = rightBlock;
			}
			else
			{
				blocks.grid[colLeft][row] = null;
			}

			canPress = false;
		}

		if (released)
			canPress = true;
	}

	function SetInitalPosition()
	{
		var startingBlock:Block = blocks.grid[2][3];
		setPosition(startingBlock.x - xPosModifier, startingBlock.y - yPosModifier);
		colLeft = 2;
		colRight = 3;
		row = 3;
	}
}
