package sublime_plugin;

import sublime.Window;

@:pythonImport("sublime_plugin", "WindowCommand")
extern class WindowCommand{
	var window:Window;
	// Called when the command is run.
	public function run(?args:Dynamic) : Void;
	// Returns true if the command is able to be run at this time. The default implementation simply always returns True.
	public function is_enabled(?args:Dynamic) : Bool;
	// Returns true if the command should be shown in the menu at this time. The default implementation always returns True.
	public function is_visible(?args:Dynamic) : Bool;
	// Returns a description of the command with the given arguments. Used in the menu, if no caption is provided. Return None to get the default description.
	public function description(?args:Dynamic) : String;
}