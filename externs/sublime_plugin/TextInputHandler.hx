package sublime_plugin;
@:pythonImport("sublime_plugin", "TextInputHandler") extern class TextInputHandler {
	/**
		The command argument name this input handler is editing. Defaults to foo_bar for an input handler named FooBarInputHandler
	**/
	function name():String;
	/**
		Placeholder text is shown in the text entry box before the user has entered anything. Empty by default.
	**/
	function placeholder():String;
	/**
		Initial text shown in the text entry box. Empty by default.
	**/
	function initial_text():String;
	/**
		Called whenever the user changes the text in the entry box. The returned value (either plain text or HTML) will be shown in the preview area of the Command Palette.
	**/
	function preview(text:String):Any;
	/**
		Called whenever the user presses enter in the text entry box. Return False to disallow the current value.
	**/
	function validate(text:String):Bool;
	/**
		Called when the input handler is canceled, either by the user pressing backspace or escape.
	**/
	function cancel():Void;
	/**
		Called when the input is accepted, after the user has pressed enter and the text has been validated.
	**/
	function confirm(text:String):Void;
	/**
		Returns the next input after the user has completed this one. May return None to indicate no more input is required, or sublime_plugin.Back() to indicate that the input handler should be poped off the stack instead.
	**/
	function next_input(args:haxe.DynamicAccess<Any>):Null<haxe.extern.EitherType<sublime_plugin.TextInputHandler, sublime_plugin.ListInputHandler>>;
	/**
		The text to show in the Command Palette when this input handler is not at the top of the input handler stack. Defaults to the text the user entered.
	**/
	function description(text:String):String;
}