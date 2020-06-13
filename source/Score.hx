import flixel.util.FlxSignal;

class Score
{
	var score:Int = 0;

	public var updateScore(default, default):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new() {}

	public function CalculateScore(_blockCount:Int, _chain:Int)
	{
		var scoreToAdd:Int = 0;

		switch (_blockCount)
		{
			case 3:
				scoreToAdd += 10;
			case 4:
				scoreToAdd += 20;
			case 5:
				scoreToAdd += 30;
			case 6:
				scoreToAdd += 50;
			case 7:
				scoreToAdd += 60;
			case 8:
				scoreToAdd += 70;
			case 9:
				scoreToAdd += 80;
			case 10:
				scoreToAdd += 100;
			case 11:
				scoreToAdd += 140;
			case 12:
				scoreToAdd += 170;
		}

		switch (_chain)
		{
			case 2:
				scoreToAdd += 50;
			case 3:
				scoreToAdd += 80;
			case 4:
				scoreToAdd += 150;
			case 5:
				scoreToAdd += 300;
			case 6:
				scoreToAdd += 400;
			case 7:
				scoreToAdd += 500;
			case 8:
				scoreToAdd += 700;
			case 9:
				scoreToAdd += 900;
			case 10:
				scoreToAdd += 1100;
			case 11:
				scoreToAdd += 1300;
			case 12:
				scoreToAdd += 1500;
			case 13:
				scoreToAdd += 1800;
			case 14:
				scoreToAdd += 2000;
		}

		score += scoreToAdd;
		updateScore.dispatch(score);
	}
}
