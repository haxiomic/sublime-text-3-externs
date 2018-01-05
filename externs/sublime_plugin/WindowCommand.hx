package sublime_plugin;
@:pythonImport("sublime_plugin", "WindowCommand") extern class WindowCommand {
	/**
		Called when the command is run.
	**/
	function run(?args:haxe.DynamicAccess<Any>):Void;
	/**
		Returns True if the command is able to be run at this time. The default implementation simply always returns True.
	**/
	function is_enabled(?args:haxe.DynamicAccess<Any>):Bool;
	/**
		Returns True if the command should be shown in the menu at this time. The default implementation always returns True.
	**/
	function is_visible(?args:haxe.DynamicAccess<Any>):Bool;
	/**
		Returns a description of the command with the given arguments. Used in the menu, if no caption is provided. Return None to get the default description.
	**/
	function description(?args:haxe.DynamicAccess<Any>):String;
	/**
		If this returns something other than None, the user will be prompted for an input before the command is run in the Command Palette.
	**/
	function input(args:haxe.DynamicAccess<Any>):Null<haxe.extern.EitherType<sublime_plugin.TextInputHandler, sublime_plugin.ListInputHandler>>;
}