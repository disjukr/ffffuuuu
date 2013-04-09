package;
import Sys;
import sys.io.File;

class FFFFUUUU
{
	public static function main()
	{
		var args = Sys.args();
		var extendedType = 0;
		var selfModifying = false;
		var code = null;
		switch (args.length)
		{
			case 0:
				printHelp();
			case 1:
				switch (args[0])
				{
					case "-h", "--h", "-help", "--help":
						printHelp();
					default:
						try
						{
							Brainfuck.interpret(File.getContent(args[0]));
						}
						catch (e:Dynamic)
						{
							Sys.println("File does not exist: " + args[0]);
						}
				}
			default:
				for (i in 0...args.length)
				{
					switch (args[i])
					{
						case "-x", "--extended":
							extendedType = 1;
						case "-s", "--selfmodifying":
							selfModifying = true;
						case "-c", "--code":
							code = args[i + 1];
						case "-h", "--h", "-help", "--help":
							printHelp();
							return;
					}
				}
				if (code != null)
				{
					Brainfuck.interpret(code, [], true, selfModifying, extendedType);
				}
				else
				{
					try
					{
						Brainfuck.interpret(File.getContent(args[args.length - 1]),
											[], true, selfModifying, extendedType);
					}
					catch (e:Dynamic)
					{
						Sys.println("File does not exist: " + args[args.length - 1]);
					}
				}
		}
	}
	
	static function printHelp()
	{
		Sys.println("Usage: ffffuuuu [options] <filename>|-c <code>");
		Sys.println("Options:");
		Sys.println(" -h, --help: Print this list");
		Sys.println(" -x, --extended: Interpret extended type 1");
		Sys.println(" -s, --selfmodifying: Interpret self-modifying brainfuck.");
		Sys.println(" -c <code>, --code <code>: Interpret the code.");
	}
}