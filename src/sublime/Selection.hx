package sublime;

import python.lib.Set;

@:pythonImport("sublime", "Selection")
extern class Selection{
	// Removes all regions.
	public function clear() : Void;
	// Adds the given region. It will be merged with any intersecting regions already contained within the set.
	public function add(region:Region) : Void;
	// Adds all regions in the given set.
	public function add_all(region_set:Set<Region>) : Void;
	// Subtracts the region from all regions in the set.
	public function subtract(region:Region) : Void;
	// Returns true if the given region is a subset.
	public function contains(region:Region) : Bool;
} 