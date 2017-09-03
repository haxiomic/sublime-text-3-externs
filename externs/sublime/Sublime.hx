package sublime;
extern class Sublime {
	/**
		Runs the callback in the main thread after the given delay (in milliseconds). Callbacks with an equal delay will be run in the order they were added.
	**/
	function set_timeout(callback:Any -> Void, delay:String):Void;
	/**
		Runs the callback on an alternate thread after the given delay (in milliseconds).
	**/
	function set_timeout_async(callback:Any -> Void, delay:String):Void;
	/**
		Displays an error dialog to the user.
	**/
	function error_message(string:String):Void;
	/**
		Displays a message dialog to the user.
	**/
	function message_dialog(string:String):Void;
	/**
		Displays an ok / cancel question dialog to the user. If ok_title is provided, this may be used as the text on the ok button. Returns True if the user presses the ok button.
	**/
	function ok_cancel_dialog(string:String, ?ok_title:String):Bool;
	/**
		Displays a yes / no / cancel question dialog to the user. If yes_title and/or no_title are provided, they will be used as the text on the corresponding buttons on some platforms. Returns sublime.DIALOG_YES, sublime.DIALOG_NO or sublime.DIALOG_CANCEL.
	**/
	function yes_no_cancel_dialog(string:String, ?yes_title:String, ?no_title:String):Int;
	/**
		Loads the given resource. The name should be in the format Packages/Default/Main.sublime-menu.
	**/
	function load_resource(name:String):String;
	/**
		Loads the given resource. The name should be in the format Packages/Default/Main.sublime-menu.
	**/
	function load_binary_resource(name:String):python.Bytes;
	/**
		Finds resources whose file name matches the given pattern.
	**/
	function find_resources(pattern:EReg):Array<String>;
	/**
		Encode a JSON compatible value into a string representation. If pretty is set to True, the string will include newlines and indentation.
	**/
	function encode_value(value:Any, ?pretty:Bool):String;
	/**
		Decodes a JSON string into an object. If the string is invalid, a ValueError will be thrown.
	**/
	function decode_value(string:String):Any;
	/**
		Expands any variables in the string value using the variables defined in the dictionary variables. value may also be a list or dict, in which case the structure will be recursively expanded. Strings should use snippet syntax, for example: expand_variables("Hello, ${name}", {"name": "Foo"})
	**/
	function expand_variables(value:Any, variables:haxe.DynamicAccess<Any>):Any;
	/**
		Loads the named settings. The name should include a file name and extension, but not a path. The packages will be searched for files matching the base_name, and the results will be collated into the settings object. Subsequent calls to load_settings() with the base_name will return the same object, and not load the settings from disk again.
	**/
	function load_settings(base_name:String):sublime.Settings;
	/**
		Flushes any in-memory changes to the named settings object to disk.
	**/
	function save_settings(base_name:String):Void;
	/**
		Returns a list of all the open windows.
	**/
	function windows():Array<sublime.Window>;
	/**
		Returns the most recently used window.
	**/
	function active_window():sublime.Window;
	/**
		Returns the path where all the user's loose packages are located.
	**/
	function packages_path():String;
	/**
		Returns the path where all the user's .sublime-package files are located.
	**/
	function installed_packages_path():String;
	/**
		Returns the path where Sublime Text stores cache files.
	**/
	function cache_path():String;
	/**
		Returns the contents of the clipboard. size_limit is there to protect against unnecessarily large data, defaults to 16,777,216 characters
	**/
	function get_clipboard(?size_limit:String):String;
	/**
		Sets the contents of the clipboard.
	**/
	function set_clipboard(string:String):Void;
	/**
		Matches the selector against the given scope, returning a score. A score of 0 means no match, above 0 means a match. Different selectors may be compared against the same scope: a higher score means the selector is a better match for the scope.
	**/
	function score_selector(scope:String, selector:String):Int;
	/**
		Runs the named ApplicationCommand with the (optional) given args.
	**/
	function run_command(string:String, ?args:haxe.DynamicAccess<Any>):Void;
	/**
		Controls command logging. If enabled, all commands run from key bindings and the menu will be logged to the console.
	**/
	function log_commands(flag:Bool):Void;
	/**
		Controls input logging. If enabled, all key presses will be logged to the console.
	**/
	function log_input(flag:Bool):Void;
	/**
		Controls result regex logging. This is useful for debugging regular expressions used in build systems.
	**/
	function log_result_regex(flag:Bool):Void;
	/**
		Returns the version number
	**/
	function version():String;
	/**
		Returns the platform, which may be "osx", "linux" or "windows"
	**/
	function platform():String;
	/**
		Returns the CPU architecture, which may be "x32" or "x64"
	**/
	function arch():String;
	static var DIALOG_YES : Int;
	static var DIALOG_NO : Int;
	static var DIALOG_CANCEL : Int;
	static var CLASS_WORD_START : Int;
	static var CLASS_WORD_END : Int;
	static var CLASS_PUNCTUATION_START : Int;
	static var CLASS_PUNCTUATION_END : Int;
	static var CLASS_SUB_WORD_START : Int;
	static var CLASS_SUB_WORD_END : Int;
	static var CLASS_LINE_START : Int;
	static var CLASS_LINE_END : Int;
	static var CLASS_EMPTY_LINE : Int;
	static var CLASS_XXX : Int;
	static var LITERAL : Int;
	static var IGNORECASE : Int;
	static var DRAW_EMPTY : Int;
	static var HIDE_ON_MINIMAP : Int;
	static var DRAW_EMPTY_AS_OVERWRITE : Int;
	static var DRAW_NO_FILL : Int;
	static var DRAW_NO_OUTLINE : Int;
	static var DRAW_SOLID_UNDERLINE : Int;
	static var DRAW_STIPPLED_UNDERLINE : Int;
	static var DRAW_SQUIGGLY_UNDERLINE : Int;
	static var PERSISTENT : Int;
	static var HIDDEN : Int;
	static var COOPERATE_WITH_AUTO_COMPLETE : Int;
	static var HIDE_ON_MOUSE_MOVE : Int;
	static var HIDE_ON_MOUSE_MOVE_AWAY : Int;
	static var LAYOUT_INLINE : Int;
	static var LAYOUT_BELOW : Int;
	static var LAYOUT_BLOCK : Int;
	static var ENCODED_POSITION : Int;
	static var TRANSIENT : Int;
	static var MONOSPACE_FONT : Int;
	static var KEEP_OPEN_ON_FOCUS_LOST : Int;
	static var HOVER_TEXT : Int;
	static var HOVER_GUTTER : Int;
	static var HOVER_MARGIN : Int;
	static var OP_EQUAL : Int;
	static var OP_NOT_EQUAL : Int;
	static var OP_REGEX_MATCH : Int;
	static var OP_NOT_REGEX_MATCH : Int;
	static var OP_REGEX_CONTAINS : Int;
	static var OP_NOT_REGEX_CONTAINS : Int;
	static var INHIBIT_WORD_COMPLETIONS : Int;
	static var INHIBIT_EXPLICIT_COMPLETIONS : Int;
}