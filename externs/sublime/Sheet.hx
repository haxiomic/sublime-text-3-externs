package sublime;
@:pythonImport("sublime", "Sheet") extern class Sheet {
	/**
		Returns a number that uniquely identifies this sheet.
	**/
	function id():Int;
	/**
		Returns the window containing the sheet. May be None if the sheet has been closed.
	**/
	function window():Null<sublime.Window>;
	/**
		Returns the view contained within the sheet. May be None if the sheet is an image preview, or the view has been closed.
	**/
	function view():Null<sublime.View>;
}