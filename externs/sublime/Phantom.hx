package sublime;
@:pythonImport("sublime", "Phantom") extern class Phantom {
	/**
		Creates a phantom attached to a region. The content is HTML to be processed by minihtml.
		
		layout must be one of:
		
		sublime.LAYOUT_INLINE: Display the phantom in between the region and the point following.
		
		sublime.LAYOUT_BELOW: Display the phantom in space below the current line, left-aligned with the region.
		
		sublime.LAYOUT_BLOCK: Display the phantom in space below the current line, left-aligned with the beginning of the line.
		
		on_navigate is an optional callback that should accept a single string parameter, that is the href attribute of the link clicked.
	**/
	function new(region:sublime.Region, content:String, layout:Int, ?on_navigate:Any -> Void);
}