package;
import Sys;

class Brainfuck
{
	public static function interpret(source:String,
									 ?memory:Array<Int>,
									 oneByteOverflow:Bool = true,
									 selfModifying:Bool = false,
									 extendedType:Int = 0)
	{
		var data:Data = cast {
			storage: new Cell(0, oneByteOverflow),
			source: Cell.fromString(source, oneByteOverflow),
			memory: Cell.fromArray(memory, oneByteOverflow)
		}
		if (selfModifying)
			Cell.concatenate([data.storage, data.source, data.memory]);
		while (data.source != null)
		{
			switch (extendedType)
			{
				case 0:
					original(data);
				case 1:
					extendedType1(data) ||
					original(data);
				case 2:
					extendedType2(data) ||
					extendedType1(data) ||
					original(data);
				case 3:
					extendedType3(data) ||
					extendedType2(data) ||
					extendedType1(data) ||
					original(data);
			}
		}
	}
	
	static function original(data:Data):Bool
	{
		var loop = 0;
		switch (data.source.character)
		{
			case ">":
				data.memory = data.memory.getRight();
			case "<":
				data.memory = data.memory.getLeft();
			case "+":
				++data.memory.value;
			case "-":
				--data.memory.value;
			case ".":
				Sys.print(data.memory.character);
			case ",":
				Sys.print("> ");
				data.memory.value = Sys.stdin().readLine().charCodeAt(0);
			case "[":
				if (data.memory.value == 0)
				{
					loop = 1;
					while ((loop > 0) && (data.source.right != null))
					{
						switch (cast (data.source = data.source.right).character)
						{
							case "[":
								++loop;
							case "]":
								--loop;
						}
					}
				}
			case "]":
				loop = 1;
				while ((loop > 0) && (data.source.left != null))
				{
					switch (cast (data.source = data.source.left).character)
					{
						case "[":
							--loop;
						case "]":
							++loop;
					}
				}
				data.source = data.source.left;
		}
		data.source = data.source.right;
		return true;
	}
	
	static function extendedType1(data:Data):Bool
	{
		switch (data.source.character)
		{
			case "@":
				data.source.setRight(null);
			case "$":
				data.storage.value = data.memory.value;
			case "!":
				data.memory.value = data.storage.value;
			case "}":
				data.memory.value = data.memory.value >>> 1;
			case "{":
				data.memory.value = data.memory.value << 1;
			case "~":
				data.memory.value = ~data.memory.value;
			case "^":
				data.memory.value = data.memory.value ^ data.storage.value;
			case "&":
				data.memory.value = data.memory.value & data.storage.value;
			case "|":
				data.memory.value = data.memory.value | data.storage.value;
			default:
				return false;
		}
		data.source = data.source.right;
		return true;
	}
	
	static function extendedType2(data:Data):Bool
	{
		return false;
		//TODO: implement;
	}
	
	static function extendedType3(data:Data):Bool
	{
		return false;
		//TODO: implement;
	}
}

private typedef Data = {
	var storage:Cell;
	var source:Cell;
	var memory:Cell;
}

private class Cell
{
	public var oneByteOverflow:Bool;
	public var value(default, set_value):Int;
	public var character(get_character, null):String;
	public var left(default, null):Cell;
	public var right(default, null):Cell;
	public var leftmost(get_leftmost, null):Cell;
	public var rightmost(get_rightmost, null):Cell;
	
	public function new(value:Int,
						?left:Cell,
						?right:Cell,
						oneByteOverflow = true)
	{
		this.value = value;
		setLeft(left);
		setRight(right);
		this.oneByteOverflow = oneByteOverflow;
	}
	
	public static function fromString(string:String, oneByteOverflow:Bool = true):Cell
	{
		if ((string != null) && (string.length > 0))
		{
			var cell = null;
			for (i in 0...string.length)
				cell = new Cell(string.charCodeAt(i), cell, null, oneByteOverflow);
			return cell.leftmost;
		}
		else
		{
			return new Cell(0);
		}
	}
	
	public static function fromArray(array:Array<Int>, oneByteOverflow:Bool = true):Cell
	{
		if ((array != null) && (array.length > 0))
		{
			var cell = null;
			for (i in 0...array.length)
				cell = new Cell(array[i], cell, null, oneByteOverflow);
			return cell.leftmost;
		}
		else
		{
			return new Cell(0);
		}
	}
	
	public static function concatenate(cells:Array<Cell>):Void
	{
		for (i in 0...cells.length)
			cells[i].rightmost.setRight(cells[i + 1]);
	}
	
	public function toString():String
	{
		var buffer = new StringBuf();
		buffer.add("Cell '");
		buffer.addChar(this.value);
		buffer.add("' in '");
		var cell = this.leftmost;
		while (cell != null)
		{
			buffer.addChar(cell.value);
			cell = cell.right;
		}
		buffer.addChar("'".code);
		return buffer.toString();
	}
	
	public function getLeft():Cell
	{
		if (left != null) return left;
		else return left = new Cell(0, null, this, this.oneByteOverflow);
	}
	
	public function getRight():Cell
	{
		if (right != null) return right;
		else return right = new Cell(0, this, null, this.oneByteOverflow);
	}
	
	public function setLeft(value)
	{
		left = value;
		if (left != null)
			left.right = this;
	}
	
	public function setRight(value)
	{
		right = value;
		if (right != null)
			right.left = this;
	}
	
	function set_value(x)
	{
		value = x;
		if (oneByteOverflow)
			value = value & 0xff;
		return value;
	}
	
	function get_character()
	{
		return String.fromCharCode(value);
	}

	function get_leftmost()
	{
		var cell = this;
		while (cell.left != null)
			cell = cell.left;
		return cell;
	}

	function get_rightmost()
	{
		var cell = this;
		while (cell.right != null)
			cell = cell.right;
		return cell;
	}
}