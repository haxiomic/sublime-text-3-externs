package sublime;
@:pythonImport("sublime", "PhantomSet") extern class PhantomSet {
	/**
		Creates a PhantomSet attached to a view. key is a string to group Phantoms together.
	**/
	function new(view:sublime.View, ?key:String);
	/**
		phantoms should be a list of phantoms.
		
		The .region attribute of each existing phantom in the set will be updated.  New phantoms will be added to the view and phantoms not in phantoms list will be deleted.
	**/
	function update(phantoms:sublime.Phantom):Void;
}