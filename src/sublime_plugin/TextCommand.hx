package sublime_plugin;

import sublime.Edit;

@:pythonImport("sublime_plugin", "TextCommand")
extern class TextCommand{
	var view:sublime.View;
	public function run(edit:Edit):Void;	//	Called when the command is run.
	public function is_enabled():Bool;		//	Returns true if the command is able to be run at this time. The default implementation simply always returns True.
	public function is_visible():Bool;		//	Returns true if the command should be shown in the menu at this time. The default implementation always returns True.
	public function description():String;	//	Returns a description of the command with the given arguments. Used in the menus, and for Undo / Redo descriptions. Return None to get the default description.
}