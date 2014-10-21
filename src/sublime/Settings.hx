//@todo, check key and on_change types

package sublime;

@:pythonImport("sublime", "Settings")
extern class Settings{
	// Returns the named setting, or default if it's not defined.
	@:overload(function (name:String, _default:Dynamic) : Dynamic{})
	// Returns the named setting.
	public function get(name:String) : Dynamic;
	// Sets the named setting. Only primitive types, lists, and dictionaries are accepted.
	public function set(name:String, value:Dynamic) : Void;
	// Removes the named setting. Does not remove it from any parent Settings.
	public function erase(name:String) : Void;
	// Returns true if the named option exists in this set of Settings or one of its parents.
	public function has(name:String) : Bool;
	// Register a callback to be run whenever a setting in this object is changed.
	public function add_on_change(key:Dynamic, on_change:Dynamic) : Void;
	// Remove all callbacks registered with the given key.
	public function clear_on_change(key:Dynamic) : Void; 
}