class TestPlugin extends sublime_plugin.EventListener {

	static function main(){
		trace('Hello Test Plugin! ${sublime.Sublime.version()}');
	}

}