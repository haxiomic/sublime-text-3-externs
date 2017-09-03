package sublime_plugin;
@:pythonImport("sublime_plugin", "EventListener") extern class EventListener {
	/**
		Called when a new buffer is created.
	**/
	function on_new(view:sublime.View):Void;
	/**
		Called when a new buffer is created. Runs in a separate thread, and does not block the application.
	**/
	function on_new_async(view:sublime.View):Void;
	/**
		Called when a view is cloned from an existing one.
	**/
	function on_clone(view:sublime.View):Void;
	/**
		Called when a view is cloned from an existing one. Runs in a separate thread, and does not block the application.
	**/
	function on_clone_async(view:sublime.View):Void;
	/**
		Called when the file is finished loading.
	**/
	function on_load(view:sublime.View):Void;
	/**
		Called when the file is finished loading. Runs in a separate thread, and does not block the application.
	**/
	function on_load_async(view:sublime.View):Void;
	/**
		Called when a view is about to be closed. The view will still be in the window at this point.
	**/
	function on_pre_close(view:sublime.View):Void;
	/**
		Called when a view is closed (note, there may still be other views into the same buffer).
	**/
	function on_close(view:sublime.View):Void;
	/**
		Called just before a view is saved.
	**/
	function on_pre_save(view:sublime.View):Void;
	/**
		Called just before a view is saved. Runs in a separate thread, and does not block the application.
	**/
	function on_pre_save_async(view:sublime.View):Void;
	/**
		Called after a view has been saved.
	**/
	function on_post_save(view:sublime.View):Void;
	/**
		Called after a view has been saved. Runs in a separate thread, and does not block the application.
	**/
	function on_post_save_async(view:sublime.View):Void;
	/**
		Called after changes have been made to a view.
	**/
	function on_modified(view:sublime.View):Void;
	/**
		Called after changes have been made to a view. Runs in a separate thread, and does not block the application.
	**/
	function on_modified_async(view:sublime.View):Void;
	/**
		Called after the selection has been modified in a view.
	**/
	function on_selection_modified(view:sublime.View):Void;
	/**
		Called after the selection has been modified in a view. Runs in a separate thread, and does not block the application.
	**/
	function on_selection_modified_async(view:sublime.View):Void;
	/**
		Called when a view gains input focus.
	**/
	function on_activated(view:sublime.View):Void;
	/**
		Called when a view gains input focus. Runs in a separate thread, and does not block the application.
	**/
	function on_activated_async(view:sublime.View):Void;
	/**
		Called when a view loses input focus.
	**/
	function on_deactivated(view:sublime.View):Void;
	/**
		Called when a view loses input focus. Runs in a separate thread, and does not block the application.
	**/
	function on_deactivated_async(view:sublime.View):Void;
	/**
		Called when the user's mouse hovers over a view for a short period.
		
		point is the closest point in the view to the mouse location. The mouse may not actually be located adjacent based on the value of hover_zone:
		
		sublime.HOVER_TEXT: When the mouse is hovered over text.
		
		sublime.HOVER_GUTTER: When the mouse is hovered over the gutter.
		
		sublime.HOVER_MARGIN: When the mouse is hovered in whitespace to the right of a line.
	**/
	function on_hover(view:sublime.View, point:String, hover_zone:Int):Void;
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
	function on_query_context(view:sublime.View, key:String, operator:Int, operand:Any, match_all:Bool):Null<Bool>;
	/**
		Called whenever completions are to be presented to the user. The prefix is a unicode string of the text to complete.
		
		locations is a list of points. Since this method is called for all completions in every view no matter the syntax, view.match_selector(point, relevant_scope) should be called to determine if the point is relevant.
		
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
	function on_query_completions(view:sublime.View, prefix:String, locations:python.Tuple<String, String, python.Tuple<Int, Int>>):Any;
	/**
		Called when a text command is issued. The listener may return a (command, arguments) tuple to rewrite the command, or None to run the command unmodified.
	**/
	function on_text_command(view:sublime.View, command_name:String, args:haxe.DynamicAccess<Any>):python.Tuple<String, python.Dict>;
	/**
		Called when a window command is issued. The listener may return a (command, arguments) tuple to rewrite the command, or None to run the command unmodified.
	**/
	function on_window_command(window:sublime.Window, command_name:String, args:haxe.DynamicAccess<Any>):python.Tuple<String, python.Dict>;
	/**
		Called after a text command has been executed.
	**/
	function on_post_text_command(view:sublime.View, command_name:String, args:haxe.DynamicAccess<Any>):Void;
	/**
		Called after a window command has been executed.
	**/
	function on_post_window_command(window:sublime.Window, command_name:String, args:haxe.DynamicAccess<Any>):Void;
}