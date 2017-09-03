package sublime;
@:pythonImport("sublime", "Window") extern class Window {
	/**
		Returns a number that uniquely identifies this window.
	**/
	function id():Int;
	/**
		Creates a new file. The returned view will be empty, and its is_loaded() method will return True.
	**/
	function new_file():sublime.View;
	/**
		Opens the named file, and returns the corresponding view. If the file is already opened, it will be brought to the front. Note that as file loading is asynchronous, operations on the returned view won't be possible until its is_loading() method returns False.
		
		The optional flags parameter is a bitwise combination of:
		
		sublime.ENCODED_POSITION: Indicates the file_name should be searched for a :row or :row:col suffix
		
		sublime.TRANSIENT: Open the file as a preview only: it won't have a tab assigned it until modified
	**/
	function open_file(file_name:String, ?flags:Bool):sublime.View;
	/**
		Finds the named file in the list of open files, and returns the corresponding View, or None if no such file is open.
	**/
	function find_open_file(file_name:String):sublime.View;
	/**
		Returns the currently focused sheet.
	**/
	function active_sheet():sublime.Sheet;
	/**
		Returns the currently edited view.
	**/
	function active_view():sublime.View;
	/**
		Returns the currently focused sheet in the given group.
	**/
	function active_sheet_in_group(group:Int):sublime.Sheet;
	/**
		Returns the currently edited view in the given group.
	**/
	function active_view_in_group(group:Int):sublime.View;
	/**
		Returns all open sheets in the window.
	**/
	function sheets():Array<sublime.Sheet>;
	/**
		Returns all open sheets in the given group.
	**/
	function sheets_in_group(group:Int):Array<sublime.Sheet>;
	/**
		Returns all open views in the window.
	**/
	function views():Array<sublime.View>;
	/**
		Returns all open views in the given group.
	**/
	function views_in_group(group:Int):Array<sublime.View>;
	/**
		Returns the number of view groups in the window.
	**/
	function num_groups():Int;
	/**
		Returns the index of the currently selected group.
	**/
	function active_group():Int;
	/**
		Makes the given group active.
	**/
	function focus_group(group:Int):Void;
	/**
		Switches to the given sheet.
	**/
	function focus_sheet(sheet:sublime.Sheet):Void;
	/**
		Switches to the given view.
	**/
	function focus_view(view:sublime.View):Void;
	/**
		Returns the group, and index within the group of the sheet. Returns -1 if not found.
	**/
	function get_sheet_index(sheet:sublime.Sheet):python.Tuple.Tuple2<Int, Int>;
	/**
		Moves the sheet to the given group and index.
	**/
	function set_sheet_index(sheet:sublime.Sheet, group:Int, index:String):Void;
	/**
		Returns the group, and index within the group of the view. Returns -1 if not found.
	**/
	function get_view_index(view:sublime.View):python.Tuple.Tuple2<Int, Int>;
	/**
		Moves the view to the given group and index.
	**/
	function set_view_index(view:sublime.View, group:Int, index:String):Void;
	/**
		Show a message in the status bar.
	**/
	function status_message(string:String):Void;
	/**
		Returns True if the menu is visible.
	**/
	function is_menu_visible():Bool;
	/**
		Controls if the menu is visible.
	**/
	function set_menu_visible(flag:Bool):Void;
	/**
		Returns True if the sidebar will be shown when contents are available.
	**/
	function is_sidebar_visible():Bool;
	/**
		Sets the sidebar to be shown or hidden when contents are available.
	**/
	function set_sidebar_visible(flag:Bool):Void;
	/**
		Returns True if tabs will be shown for open files.
	**/
	function get_tabs_visible():Bool;
	/**
		Controls if tabs will be shown for open files.
	**/
	function set_tabs_visible(flag:Bool):Void;
	/**
		Returns True if the minimap is enabled.
	**/
	function is_minimap_visible():Bool;
	/**
		Controls the visibility of the minimap.
	**/
	function set_minimap_visible(flag:Bool):Void;
	/**
		Returns True if the status bar will be shown.
	**/
	function is_status_bar_visible():Bool;
	/**
		Controls the visibility of the status bar.
	**/
	function set_status_bar_visible(flag:Bool):Void;
	/**
		Returns a list of the currently open folders.
	**/
	function folders():Array<String>;
	/**
		Returns name of the currently opened project file, if any.
	**/
	function project_file_name():String;
	/**
		Returns the project data associated with the current window. The data is in the same format as the contents of a .sublime-project file.
	**/
	function project_data():python.Dict<String, Any>;
	/**
		Updates the project data associated with the current window. If the window is associated with a .sublime-project file, the project file will be updated on disk, otherwise the window will store the data internally.
	**/
	function set_project_data(data:python.Dict<String, Any>):Void;
	/**
		Runs the named WindowCommand with the (optional) given args. This method is able to run any sort of command, dispatching the command via input focus.
	**/
	function run_command(string:String, ?args:haxe.DynamicAccess<Any>):Void;
	/**
		Shows a quick panel, to select an item in a list. on_done will be called once, with the index of the selected item. If the quick panel was cancelled, on_done will be called with an argument of -1.
		
		items may be a list of strings, or a list of string lists. In the latter case, each entry in the quick panel will show multiple rows.
		
		flags is a bitwise OR of sublime.MONOSPACE_FONT and sublime.KEEP_OPEN_ON_FOCUS_LOST
		
		on_highlighted, if given, will be called every time the highlighted item in the quick panel is changed.
	**/
	function show_quick_panel(items:String, on_done:Any -> Void, ?flags:Bool, ?selected_index:String, ?on_highlighted:Any -> Void):Void;
	/**
		Shows the input panel, to collect a line of input from the user. on_done and on_change, if not None, should both be functions that expect a single string argument. on_cancel should be a function that expects no arguments. The view used for the input widget is returned.
	**/
	function show_input_panel(caption:String, initial_text:String, on_done:Any -> Void, on_change:Any -> Void, on_cancel:Any -> Void):sublime.View;
	/**
		Returns the view associated with the named output panel, creating it if required. The output panel can be shown by running the show_panel window command, with the panel argument set to the name with an "output." prefix.
		
		The optional unlisted parameter is a boolean to control if the output panel should be listed in the panel switcher.
	**/
	function create_output_panel(name:String, ?unlisted:Bool):sublime.View;
	/**
		Returns the view associated with the named output panel, or None if the output panel does not exist.
	**/
	function find_output_panel(name:String):Null<sublime.View>;
	/**
		Destroys the named output panel, hiding it if currently open.
	**/
	function destroy_output_panel(name:String):Void;
	/**
		Returns the name of the currently open panel, or None if no panel is open. Will return built-in panel names (e.g. "console", "find", etc) in addition to output panels.
	**/
	function active_panel():Null<String>;
	/**
		Returns a list of the names of all panels that have not been marked as unlisted. Includes certain built-in panels in addition to output panels.
	**/
	function panels():Array<String>;
	/**
		Returns all locations where the symbol is defined across files in the current project.
	**/
	function lookup_symbol_in_index(symbol:String):Array<python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>>;
	/**
		Returns all locations where the symbol is defined across open files.
	**/
	function lookup_symbol_in_open_files(symbol:String):Array<python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>>;
	/**
		Returns a dictionary of strings populated with contextual keys:
		
		packages, platform, file, file_path, file_name, file_base_name, file_extension, folder, project, project_path, project_name, project_base_name, project_extension. This dict is suitable for passing to sublime.expand_variables().
	**/
	function extract_variables():python.Dict<String, Any>;
}