package sublime_plugin;
@:pythonImport("sublime_plugin", "ViewEventListener") extern class ViewEventListener {
	/**
		A @classmethod that receives a Settings object and should return a bool indicating if this class applies to a view with those settings
	**/
	function is_applicable(settings:sublime.Settings):Bool;
	/**
		A @classmethod that should return a bool indicating if this class applies only to the primary view for a file. A view is considered primary if it is the only, or first, view into a file.
	**/
	function applies_to_primary_view_only():Bool;
	/**
		Called after changes have been made to the view.
	**/
	function on_modified():Void;
	/**
		Called after changes have been made to the view. Runs in a separate thread, and does not block the application.
	**/
	function on_modified_async():Void;
	/**
		Called after the selection has been modified in the view.
	**/
	function on_selection_modified():Void;
	/**
		Called after the selection has been modified in the view. Runs in a separate thread, and does not block the application.
	**/
	function on_selection_modified_async():Void;
	/**
		Called when a view gains input focus.
	**/
	function on_activated():Void;
	/**
		Called when the view gains input focus. Runs in a separate thread, and does not block the application.
	**/
	function on_activated_async():Void;
	/**
		Called when the view loses input focus.
	**/
	function on_deactivated():Void;
	/**
		Called when the view loses input focus. Runs in a separate thread, and does not block the application.
	**/
	function on_deactivated_async():Void;
	/**
		Called when the user's mouse hovers over the view for a short period.
		
		point is the closest point in the view to the mouse location. The mouse may not actually be located adjacent based on the value of hover_zone:
		
		sublime.HOVER_TEXT: When the mouse is hovered over text.
		
		sublime.HOVER_GUTTER: When the mouse is hovered over the gutter.
		
		sublime.HOVER_MARGIN: When the mouse is hovered in whitespace to the right of a line.
	**/
	function on_hover(point:Int, hover_zone:Int):Void;
	/**
		Called when determining to trigger a key binding with the given context key. If the plugin knows how to respond to the context, it should return either True of False. If the context is unknown, it should return None.
		
		operator is one of:
		
		sublime.OP_EQUAL: Is the value of the context equal to the operand?
		
		sublime.OP_NOT_EQUAL: Is the value of the context not equal to the operand?
		
		sublime.OP_REGEX_MATCH: Does the value of the context match the regex given in operand?
		
		sublime.OP_NOT_REGEX_MATCH: Does the value of the context not match the regex given in operand?
		
		sublime.OP_REGEX_CONTAINS: Does the value of the context contain a substring matching the regex given in operand?
		
		sublime.OP_NOT_REGEX_CONTAINS: Does the value of the context not contain a substring matching the regex given in operand?
		
		match_all should be used if the context relates to the selections: does every selection have to match (match_all == True), or is at least one matching enough (match_all == False)?
	**/
	function on_query_context(key:String, operator:Int, operand:Any, match_all:Bool):Null<Bool>;
	/**
		Called whenever completions are to be presented to the user. The prefix is a unicode string of the text to complete.
		
		locations is a list of points. Since this method is called for all completions no matter the syntax, self.view.match_selector(point, relevant_scope) should be called to determine if the point is relevant.
		
		The return value must be one of the following formats:
		
		None: no completions are provided
		
		return None
		
		A list of 2-element lists/tuples. The first element is a unicode string of the completion trigger, the second is the unicode replacement text.
		
		return [["me1", "method1()"], ["me2", "method2()"]]
		
		The trigger may contain a tab character (\t) followed by a hint to display in the right-hand side of the completion box.
		
		return [
		["me1\tmethod", "method1()"],
		["me2\tmethod", "method2()"]
		]
		
		The replacement text may contain dollar-numeric fields such as a snippet does, e.g. $0, $1.
		
		return [
		["fn", "def ${1:name}($2) { $0 }"],
		["for", "for ($1; $2; $3) { $0 }"]
		]
		
		A 2-element tuple with the first element being the list format documented above, and the second element being bit flags from the following list:
		
		sublime.INHIBIT_WORD_COMPLETIONS: prevent Sublime Text from showing completions based on the contents of the view
		
		sublime.INHIBIT_EXPLICIT_COMPLETIONS: prevent Sublime Text from showing completions based on .sublime-completions files
		
		return (
		[
		["me1", "method1()"],
		["me2", "method2()"]
		],
		sublime.INHIBIT_WORD_COMPLETIONS | sublime.INHIBIT_EXPLICIT_COMPLETIONS
		)
	**/
	function on_query_completions(prefix:String, locations:python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>):Any;
}