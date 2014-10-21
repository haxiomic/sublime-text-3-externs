package sublime;

@:pythonImport("sublime", "Region")
extern class Region{
	public var a:Int;
	public var b:Int;
	public var xpos:Int;
	// Creates a Region with initial values a and b.
	public function new(a:Int, b:Int):Void;
	// Returns the minimum of a and b.
	public function begin() : Int;
	// Returns the maximum of a and b.
	public function end() : Int;
	// Returns the number of characters spanned by the region. Always >= 0.
	public function size() : Int;
	// Returns true iff begin() == end().
	public function empty() : Bool;
	// Returns a Region spanning both this and the given regions.
	public function cover(region:Region) : Region;
	// Returns the set intersection of the two regions.
	public function intersection(region:Region) : Region;
	// Returns True iff this == region or both include one or more positions in common.
	public function intersects(region:Region) : Bool;
	// Returns True iff the given region is a subset.
	@:overload(function (region:Region) : Bool{})
	// Returns True iff begin() <= point <= end().
	public function contains(point:Int) : Bool;
}