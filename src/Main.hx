import sublime.Edit;

class Main{
	static function main(){}
}


//Proof of concept command, invoked with view.run_command("example")
class ExampleCommand extends sublime_plugin.TextCommand {
	override public function run(edit:Edit){
		this.view.insert(edit, 0, "Hello World");
	}
}
