package sublime;
@:pythonImport("sublime", "Selection") extern class Selection {
	/**
		Removes all regions.
	**/
	function clear():Void;
	/**
		Adds the given region. It will be merged with any intersecting regions already contained within the set.
	**/
	function add(region:sublime.Region):Void;
	/**
		Adds all regions in the given list or tuple.
	**/
	function add_all(regions:sublime.Region):Void;
	/**
		Subtracts the region from all regions in the set.
	**/
	function subtract(region:sublime.Region):Void;
	/**
		Returns True iff the given region is a subset.
	**/
	function contains(region:sublime.Region):Bool;
}