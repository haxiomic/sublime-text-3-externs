package sublime;
@:pythonImport("sublime", "Settings") extern class Settings {
	/**
		Returns the named setting, or default if it's not defined. If not passed, default will have a value of None.
	**/
	function get(name:String, ?default:Any):Any;
	/**
		Sets the named setting. Only primitive types, lists, and dicts are accepted.
	**/
	function set(name:String, value:Any):Void;
	/**
		Removes the named setting. Does not remove it from any parent Settings.
	**/
	function erase(name:String):Void;
	/**
		Returns True iff the named option exists in this set of Settings or one of its parents.
	**/
	function has(name:String):Bool;
	/**
		Register a callback to be run whenever a setting in this object is changed.
	**/
	function add_on_change(key:String, on_change:Any -> Void):Void;
	/**
		Remove all callbacks registered with the given key.
	**/
	function clear_on_change(key:String):Void;
}