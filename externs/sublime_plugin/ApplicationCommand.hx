package sublime_plugin;
@:pythonImport("sublime_plugin", "ApplicationCommand") extern class ApplicationCommand {
	/**
		Called when the command is run.
	**/
	function run(?args:python.Dict<String, Any>):Void;
	/**
		Returns True if the command is able to be run at this time. The default implementation simply always returns True.
	**/
	function is_enabled(?args:python.Dict<String, Any>):Bool;
	/**
		Returns True if the command should be shown in the menu at this time. The default implementation always returns True.
	**/
	function is_visible(?args:python.Dict<String, Any>):Bool;
	/**
		Returns True if a checkbox should be shown next to the menu item. The .sublime-menu file must have the checkbox attribute set to true for this to be used.
	**/
	function is_checked(?args:python.Dict<String, Any>):Bool;
	/**
		Returns a description of the command with the given arguments. Used in the menu, if no caption is provided. Return None to get the default description.
	**/
	function description(?args:python.Dict<String, Any>):String;
	/**
		If this returns something other than None, the user will be prompted for an input before the command is run in the Command Palette.
	**/
	function input(args:python.Dict<String, Any>):Null<haxe.extern.EitherType<sublime_plugin.TextInputHandler, sublime_plugin.ListInputHandler>>;
}