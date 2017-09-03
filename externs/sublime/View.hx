package sublime;
@:pythonImport("sublime", "View") extern class View {
	/**
		Returns a number that uniquely identifies this view.
	**/
	function id():Int;
	/**
		Returns a number that uniquely identifies the buffer underlying this view.
	**/
	function buffer_id():Int;
	/**
		If the view is the primary view into a file. Will only be False if the user has opened multiple views into a file.
	**/
	function is_primary():Bool;
	/**
		The full name file the file associated with the buffer, or None if it doesn't exist on disk.
	**/
	function file_name():String;
	/**
		The name assigned to the buffer, if any
	**/
	function name():String;
	/**
		Assigns a name to the buffer
	**/
	function set_name(name:String):Void;
	/**
		Returns True if the buffer is still loading from disk, and not ready for use.
	**/
	function is_loading():Bool;
	/**
		Returns True if there are any unsaved modifications to the buffer.
	**/
	function is_dirty():Bool;
	/**
		Returns True if the buffer may not be modified.
	**/
	function is_read_only():Bool;
	/**
		Sets the read only property on the buffer.
	**/
	function set_read_only(value:Any):Void;
	/**
		Returns True if the buffer is a scratch buffer. Scratch buffers never report as being dirty.
	**/
	function is_scratch():Bool;
	/**
		Sets the scratch property on the buffer.
	**/
	function set_scratch(value:Any):Void;
	/**
		Returns a reference to the view's settings object. Any changes to this settings object will be private to this view.
	**/
	function settings():sublime.Settings;
	/**
		Returns a reference to the window containing the view.
	**/
	function window():sublime.Window;
	/**
		Runs the named TextCommand with the (optional) given args.
	**/
	function run_command(string:String, ?args:haxe.DynamicAccess<Any>):Void;
	/**
		Returns the number of character in the file.
	**/
	function size():Int;
	/**
		Returns the contents of the region as a string.
	**/
	@:overload(function(point:String):String { })
	function substr(region:sublime.Region):String;
	/**
		Inserts the given string in the buffer at the specified point. Returns the number of characters inserted: this may be different if tabs are being translated into spaces in the current buffer.
	**/
	function insert(edit:sublime.Edit, point:String, string:String):Int;
	/**
		Erases the contents of the region from the buffer.
	**/
	function erase(edit:sublime.Edit, region:sublime.Region):Void;
	/**
		Replaces the contents of the region with the given string.
	**/
	function replace(edit:sublime.Edit, region:sublime.Region, string:String):Void;
	/**
		Returns a reference to the selection.
	**/
	function sel():sublime.Selection;
	/**
		Returns the line that contains the point.
	**/
	@:overload(function(region:sublime.Region):sublime.Region { })
	function line(point:String):sublime.Region;
	/**
		As line(), but the region includes the trailing newline character, if any.
	**/
	@:overload(function(region:sublime.Region):sublime.Region { })
	function full_line(point:String):sublime.Region;
	/**
		Returns a list of lines (in sorted order) intersecting the region.
	**/
	function lines(region:sublime.Region):Array<sublime.Region>;
	/**
		Splits the region up such that each region returned exists on exactly one line.
	**/
	function split_by_newlines(region:sublime.Region):Array<sublime.Region>;
	/**
		Returns the word that contains the point.
	**/
	@:overload(function(region:sublime.Region):sublime.Region { })
	function word(point:String):sublime.Region;
	/**
		Classifies point, returning a bitwise OR of zero or more of these flags:
		
		sublime.CLASS_WORD_START
		sublime.CLASS_WORD_END
		sublime.CLASS_PUNCTUATION_START
		sublime.CLASS_PUNCTUATION_END
		sublime.CLASS_SUB_WORD_START
		sublime.CLASS_SUB_WORD_END
		sublime.CLASS_LINE_START
		sublime.CLASS_LINE_END
		sublime.CLASS_EMPTY_LINE
	**/
	function classify(point:String):Int;
	/**
		Finds the next location after point that matches the given classes. If forward is False, searches backwards instead of forwards. classes is a bitwise OR of the sublime.CLASS_XXX flags. separators may be passed in, to define what characters should be considered to separate words.
	**/
	function find_by_class(point:String, forward:Bool, classes:Int, ?separators:String):sublime.Region;
	/**
		Expands point to the left and right, until each side lands on a location that matches classes. classes is a bitwise OR of the sublime.CLASS_XXX flags. separators may be passed in, to define what characters should be considered to separate words.
	**/
	@:overload(function(region:sublime.Region, classes:Int, ?separators:String):sublime.Region { })
	function expand_by_class(point:String, classes:Int, ?separators:String):sublime.Region;
	/**
		Returns the first region matching the regex pattern, starting from start_point, or None if it can't be found. The optional flags parameter may be sublime.LITERAL, sublime.IGNORECASE, or the two ORed together.
	**/
	function find(pattern:EReg, start_point:String, ?flags:Bool):sublime.Region;
	/**
		Returns all (non-overlapping) regions matching the regex pattern. The optional flags parameter may be sublime.LITERAL, sublime.IGNORECASE, or the two ORed together. If a format string is given, then all matches will be formatted with the formatted string and placed into the extractions list.
	**/
	function find_all(pattern:EReg, ?flags:Bool, ?format:String, ?extractions:Any):Array<sublime.Region>;
	/**
		Calculates the 0-based line and column numbers of the point.
	**/
	function rowcol(point:String):python.Tuple.Tuple2<Int, Int>;
	/**
		Calculates the character offset of the given, 0-based, row and col. Note that col is interpreted as the number of characters to advance past the beginning of the row.
	**/
	function text_point(row:String, col:String):Int;
	/**
		Changes the syntax used by the view. syntax_file should be a name along the lines of Packages/Python/Python.tmLanguage. To retrieve the current syntax, use view.settings().get('syntax').
	**/
	function set_syntax_file(syntax_file:String):Void;
	/**
		Returns the extent of the syntax scope name assigned to the character at the given point.
	**/
	function extract_scope(point:String):sublime.Region;
	/**
		Returns the syntax scope name assigned to the character at the given point.
	**/
	function scope_name(point:String):String;
	/**
		Checks the selector against the scope at the given point, returning a bool if they match.
	**/
	function match_selector(point:String, selector:String):Bool;
	/**
		Matches the selector against the scope at the given point, returning a score. A score of 0 means no match, above 0 means a match. Different selectors may be compared against the same scope: a higher score means the selector is a better match for the scope.
	**/
	function score_selector(point:String, selector:String):Int;
	/**
		Finds all regions in the file matching the given selector, returning them as a list.
	**/
	function find_by_selector(selector:String):Array<sublime.Region>;
	/**
		Scroll the view to show the given location, which may be a point, Region or Selection.
	**/
	function show(location:python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>, ?show_surrounds:Bool):Void;
	/**
		Scroll the view to center on the location, which may be a point or Region.
	**/
	function show_at_center(location:python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>):Void;
	/**
		Returns the currently visible area of the view.
	**/
	function visible_region():sublime.Region;
	/**
		Returns the offset of the viewport in layout coordinates.
	**/
	function viewport_position():python.Tuple.Tuple2<Int, Int>;
	/**
		Scrolls the viewport to the given layout position.
	**/
	function set_viewport_position(vector:python.Tuple.Tuple2<Int, Int>, ?animate:Bool):Void;
	/**
		Returns the width and height of the viewport.
	**/
	function viewport_extent():python.Tuple.Tuple2<Int, Int>;
	/**
		Returns the width and height of the layout.
	**/
	function layout_extent():python.Tuple.Tuple2<Int, Int>;
	/**
		Converts a text point to a layout position
	**/
	function text_to_layout(point:String):python.Tuple.Tuple2<Int, Int>;
	/**
		Converts a text point to a window position
	**/
	function text_to_window(point:String):python.Tuple.Tuple2<Int, Int>;
	/**
		Converts a layout position to a text point
	**/
	function layout_to_text(vector:python.Tuple.Tuple2<Int, Int>):String;
	/**
		Converts a layout position to a window position
	**/
	function layout_to_window(vector:python.Tuple.Tuple2<Int, Int>):python.Tuple.Tuple2<Int, Int>;
	/**
		Converts a window position to a layout position
	**/
	function window_to_layout(vector:python.Tuple.Tuple2<Int, Int>):python.Tuple.Tuple2<Int, Int>;
	/**
		Converts a window position to a text point
	**/
	function window_to_text(vector:python.Tuple.Tuple2<Int, Int>):String;
	/**
		Returns the light height used in the layout
	**/
	function line_height():Float;
	/**
		Returns the typical character width used in the layout
	**/
	function em_width():Float;
	/**
		Add a set of regions to the view. If a set of regions already exists with the given key, they will be overwritten. The scope is used to source a color to draw the regions in, it should be the name of a scope, such as "comment" or "string". If the scope is empty, the regions won't be drawn.
		
		The optional icon name, if given, will draw the named icons in the gutter next to each region. The icon will be tinted using the color associated with the scope. Valid icon names are dot, circle, bookmark and cross. The icon name may also be a full package relative path, such as Packages/Theme - Default/dot.png.
		
		The optional flags parameter is a bitwise combination of:
		
		sublime.DRAW_EMPTY: Draw empty regions with a vertical bar. By default, they aren't drawn at all.
		
		sublime.HIDE_ON_MINIMAP: Don't show the regions on the minimap.
		
		sublime.DRAW_EMPTY_AS_OVERWRITE: Draw empty regions with a horizontal bar instead of a vertical one.
		
		sublime.DRAW_NO_FILL: Disable filling the regions, leaving only the outline.
		
		sublime.DRAW_NO_OUTLINE: Disable drawing the outline of the regions.
		
		sublime.DRAW_SOLID_UNDERLINE: Draw a solid underline below the regions.
		
		sublime.DRAW_STIPPLED_UNDERLINE: Draw a stippled underline below the regions.
		
		sublime.DRAW_SQUIGGLY_UNDERLINE: Draw a squiggly underline below the regions.
		
		sublime.PERSISTENT: Save the regions in the session.
		
		sublime.HIDDEN: Don't draw the regions.
		
		The underline styles are exclusive, either zero or one of them should be given. If using an underline, sublime.DRAW_NO_FILL and sublime.DRAW_NO_OUTLINE should generally be passed in.
	**/
	function add_regions(key:String, regions:Array<sublime.Region>, ?scope:String, ?icon:String, ?flags:Bool):Void;
	/**
		Return the regions associated with the given key, if any
	**/
	function get_regions(key:String):Array<sublime.Region>;
	/**
		Removed the named regions
	**/
	function erase_regions(key:String):Void;
	/**
		Adds the status key to the view. The value will be displayed in the status bar, in a comma separated list of all status values, ordered by key. Setting the value to the empty string will clear the status.
	**/
	function set_status(key:String, value:Any):Void;
	/**
		Returns the previously assigned value associated with the key, if any.
	**/
	function get_status(key:String):String;
	/**
		Clears the named status.
	**/
	function erase_status(key:String):Void;
	/**
		Returns the command name, command arguments, and repeat count for the given history entry, as stored in the undo / redo stack.
		
		Index 0 corresponds to the most recent command, -1 the command before that, and so on. Positive values for index indicate to look in the redo stack for commands. If the undo / redo history doesn't extend far enough, then (None, None, 0) will be returned.
		
		Setting modifying_only to True (the default is False) will only return entries that modified the buffer.
	**/
	function command_history(index:String, ?modifying_only:Bool):python.Tuple.Tuple3<String, python.Dict<String, Any>, Int>;
	/**
		Returns the current change count. Each time the buffer is modified, the change count is incremented. The change count can be used to determine if the buffer has changed since the last it was inspected.
	**/
	function change_count():Int;
	/**
		Folds the given regions, returning False if they were already folded
	**/
	@:overload(function(region:sublime.Region):Bool { })
	function fold(regions:Array<sublime.Region>):Bool;
	/**
		Unfolds all text in the region, returning the unfolded regions
	**/
	@:overload(function(regions:Array<sublime.Region>):Array<sublime.Region> { })
	function unfold(region:sublime.Region):Array<sublime.Region>;
	/**
		Returns the encoding currently associated with the file
	**/
	function encoding():String;
	/**
		Applies a new encoding to the file. This encoding will be used the next time the file is saved.
	**/
	function set_encoding(encoding:String):Void;
	/**
		Returns the line endings used by the current file.
	**/
	function line_endings():String;
	/**
		Sets the line endings that will be applied when next saving.
	**/
	function set_line_endings(line_endings:String):Void;
	/**
		Returns the overwrite status, which the user normally toggles via the insert key.
	**/
	function overwrite_status():Bool;
	/**
		Sets the overwrite status.
	**/
	function set_overwrite_status(enabled:Bool):Void;
	/**
		Extract all the symbols defined in the buffer.
	**/
	function symbols():Array<python.Tuple.Tuple2<sublime.Region, String>>;
	/**
		Shows a pop up menu at the caret, to select an item in a list. on_done will be called once, with the index of the selected item. If the pop up menu was cancelled, on_done will be called with an argument of -1.
		
		items is a list of strings.
		
		flags it currently unused.
	**/
	function show_popup_menu(items:String, on_done:Any -> Void, ?flags:Bool):Void;
	/**
		Shows a popup displaying HTML content.
		
		flags is a bitwise combination of the following:
		
		sublime.COOPERATE_WITH_AUTO_COMPLETE. Causes the popup to display next to the auto complete menu
		
		sublime.HIDE_ON_MOUSE_MOVE. Causes the popup to hide when the mouse is moved, clicked or scrolled
		
		sublime.HIDE_ON_MOUSE_MOVE_AWAY. Causes the popup to hide when the mouse is moved (unless towards the popup), or when clicked or scrolled
		
		The default location of -1 will display the popup at the cursor, otherwise a text point should be passed.
		
		max_width and max_height set the maximum dimensions for the popup, after which scroll bars will be displayed.
		
		on_navigate is a callback that should accept a string contents of the href attribute on the link the user clicked.
		
		on_hide is called when the popup is hidden.
	**/
	function show_popup(content:String, ?flags:Bool, ?location:python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>, ?max_width:String, ?max_height:String, ?on_navigate:Any -> Void, ?on_hide:Any -> Void):Void;
	/**
		Updates the contents of the currently visible popup.
	**/
	function update_popup(content:String):Void;
	/**
		Returns if the popup is currently shown.
	**/
	function is_popup_visible():Bool;
	/**
		Hides the popup.
	**/
	function hide_popup():Void;
	/**
		Returns if the auto complete menu is currently visible.
	**/
	function is_auto_complete_visible():Bool;
}