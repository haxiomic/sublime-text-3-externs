package sublime_plugin;
@:pythonImport("sublime_plugin", "ListInputHandler") extern class ListInputHandler {
	/**
		The command argument name this input handler is editing. Defaults to foo_bar for an input handler named FooBarInputHandler
	**/
	function name():String;
	/**
		The items to show in the list. If returning a list of (str, value) tuples, then the str will be shown to the user, while the value will be used as the command argument.
		
		Optionally return a tuple of (list_items, selected_item_index) to indicate an initial selection.
	**/
	function list_items():Any;
	/**
		Placeholder text is shown in the text entry box before the user has entered anything. Empty by default.
	**/
	function placeholder():String;
	/**
		Initial text shown in the filter box. Empty by default.
	**/
	function initial_text():String;
	/**
		Called whenever the user changes the selected item. The returned value (either plain text or HTML) will be shown in the preview area of the Command Palette.
	**/
	function preview(value:Any):Any;
	/**
		Called whenever the user presses enter in the text entry box. Return False to disallow the current value.
	**/
	function validate(value:Any):Bool;
	/**
		Called when the input handler is canceled, either by the user pressing backspace or escape.
	**/
	function cancel():Void;
	/**
		Called when the input is accepted, after the user has pressed enter and the item has been validated.
	**/
	function confirm(value:Any):Void;
	/**
		Returns the next input after the user has completed this one. May return None to indicate no more input is required, or sublime_plugin.Back() to indicate that the input handler should be poped off the stack instead.
	**/
	function next_input(args:haxe.DynamicAccess<Any>):Null<Any>;
	/**
		The text to show in the Command Palette when this input handler is not at the top of the input handler stack. Defaults to the text of the list item the user selected.
	**/
	function description(value:Any, text:String):String;
}