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
			if (colLeft > 1)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([RIGHT]))
			if (colRight < 6)
				return true;
		if (_directionPressed == FlxG.keys.anyPressed([DOWN]))
			if (row > 1)
				return true;

		if (_directionPressed == FlxG.keys.anyPressed([UP])) // Will only be able to move to the highest position of a block
		{
			var highestRow:Int = 0;
			for (block in blocks)
			{
				if (block.row > highestRow)
					highestRow = block.row;
			}

			if (row < highestRow)
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
			for (block in blocks)
			{
				if (block.row == row && block.col == colLeft)
				{
					leftBlock = block;
				}
				else if (block.row == row && block.col == colRight)
				{
					rightBlock = block;
				}
			}

			if (leftBlock != null)
				leftBlock.Swap(1);
			if (rightBlock != null)
				rightBlock.Swap(-1);

			canPress = false;
		}

		if (released)
			canPress = true;
	}

	function SetInitalPosition()
	{
		for (block in blocks)
		{
			if (block.col == 3 && block.row == 3)
			{
				setPosition(block.x - xPosModifier, block.y - yPosModifier);
				colLeft = 3;
				colRight = 4;
				row = 3;
			}
		}
	}
}
