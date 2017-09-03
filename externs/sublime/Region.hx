package sublime;
@:pythonImport("sublime", "Region") extern class Region {
	/**
		Creates a Region with initial values a and b.
	**/
	function new(a:Int, b:Int);
	/**
		The first end of the region.
	**/
	var a : Int;
	/**
		The second end of the region. May be less that a, in which case the region is a reversed one.
	**/
	var b : Int;
	/**
		The target horizontal position of the region, or -1 if undefined. Effects behavior when pressing the up or down keys.
	**/
	var xpos : Int;
	/**
		Returns the minimum of a and b.
	**/
	function begin():Int;
	/**
		Returns the maximum of a and b.
	**/
	function end():Int;
	/**
		Returns the number of characters spanned by the region. Always >= 0.
	**/
	function size():Int;
	/**
		Returns True iff begin() == end().
	**/
	function empty():Bool;
	/**
		Returns a Region spanning both this and the given regions.
	**/
	function cover(region:sublime.Region):sublime.Region;
	/**
		Returns the set intersection of the two regions.
	**/
	function intersection(region:sublime.Region):sublime.Region;
	/**
		Returns True iff self == region or both include one or more positions in common.
	**/
	function intersects(region:sublime.Region):Bool;
	/**
		Returns True iff the given region is a subset.
	**/
	function contains(region:sublime.Region):Bool;
	/**
		Returns True iff begin() <= point <= end().
	**/
	function contains(point:String):Bool;
}