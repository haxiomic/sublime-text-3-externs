import haxe.io.Path;
import haxe.macro.Expr;

@:enum
abstract PythonType(String) {
	var Module = 'module';
	var Class = 'class';
	@:from static inline public function fromString(str:String):PythonType
		return untyped str.toLowerCase();
}

typedef Table = {
	columns: Array<String>,
	rows: Array<Array<String>>
}

class Main {

	static inline var downloadLatest = true; 
	var sublimeApiUrl = 'https://www.sublimetext.com/docs/3/api_reference.html';
	var downloadDir = 'api-reference';
	var externDir = '../externs';
	var titlePatern = ~/([\w.]+)\s+(Class|Module)/i;
	var titleTagName = 'h2';

	var classPathRegister = new Array<Array<String>>();
	var enumRegister = new Array<String>();

	function new(){
		if (downloadLatest) {
			Console.log('Requesting "$sublimeApiUrl"');
			var req = new haxe.Http(sublimeApiUrl);
			req.onData = function(content: String){
				// Save html to disk
				sys.FileSystem.createDirectory(downloadDir);
				sys.io.File.saveContent(haxe.io.Path.join([downloadDir, 'api-reference.html']), content);
				Console.success('Saved "${haxe.io.Path.join([downloadDir, 'api-reference.html'])}"');

				try {
					processAPIDocs(content);
				} catch (msg:String) {
					Console.debug(msg);
					throw msg;
				}
			}

			req.onStatus = function(status:Int) Console.log('Request status $status');
			req.onError = function(msg:String) Console.error(msg);

			req.request();
		} else {
			// read api html from disk
			try {
				var content = sys.io.File.getContent(haxe.io.Path.join([downloadDir, 'api-reference.html']));
				processAPIDocs(content);
			} catch (msg:String) {
				Console.debug(msg);
				throw msg;
			}
		}
	}

	function processAPIDocs(content:String){
		var html = new htmlparser.HtmlDocument(content, true);

		// Process each section as a type
		var sections = new Array<{
			syntaxType: PythonType,
			path: Array<String>,
			tables: Array<Table>
		}>();

		var titles = html.find(titleTagName);
		for(el in titles){
			var titleText = [for(node in el.nodes) node.toText()].join(' ');

			if (!titlePatern.match(titleText)) {
				Console.warn('Ignoring title "${titleText}"');
				continue;
			}

			sections.push({
				syntaxType: PythonType.fromString(titlePatern.matched(2)),
				path: titlePatern.matched(1).split('.'),
				tables: [
					for(tableEl in getTables(el)) parseTable(tableEl)
				]
			});
		}

		// Pre-register types up-front to help argument type guessing
		for(section in sections){
			registerType(section.path, section.syntaxType);
		}

		// Extract enums from descriptions
		for(section in sections){
			for(enumPath in extractEnums(section.tables)){
				registerEnum(enumPath);
			}
		}

		// Generate haxe types
		var haxeTypes = [
			for(section in sections)
				generateHaxeType(section.syntaxType, section.path, section.tables)
		].filter(function(t) return t != null);

		// Add in enums
		for(enumPath in enumRegister){
			var parts = enumPath.split('.');
			var pack = parts.slice(0, parts.length - 1);
			var parent = pack[pack.length - 1];
			var parentIsClass = toClassNameCase(parent) == parent;

			var expectedClassPath = parentIsClass ? pack.join('.') : pack.concat([toClassNameCase(parent)]).join('.');
			var matchingTypes = haxeTypes.filter(function(type) return type.pack.concat([type.name]).join('.') == expectedClassPath);
			if (matchingTypes.length == 0){
				Console.error('Could not find class for enum "$enumPath"');
			}

			matchingTypes[0].fields.push({
				name: parts[parts.length - 1],
				access: [AStatic],
				kind: FVar(macro :Int),
				pos: nullPos
			});
		}

		// Clean up types
		for(type in haxeTypes){
			deduplicateFields(type);
		}

		// Save result
		for(type in haxeTypes){
			var printer = new haxe.macro.Printer();
			var haxeStr = printer.printTypeDefinition(type);

			var filename = '${type.name}.hx';
			var directory = Path.join(type.pack);

			var savePath = Path.join([externDir, directory, filename]);
			sys.FileSystem.createDirectory(Path.directory(savePath));
			sys.io.File.saveContent(savePath, haxeStr);
			Console.success('Saved ${savePath}');
		}
	}

	// Find tables associated with a title
	function getTables(titleElement:htmlparser.HtmlNodeElement){
		var tables = new Array<htmlparser.HtmlNodeElement>();
		var currentElement = titleElement;
		while (true) {
			var nextSibling = currentElement.getNextSiblingElement();
			currentElement = nextSibling;

			if (nextSibling == null) break;

			switch nextSibling.name.toLowerCase() {
				case 'table': tables.push(nextSibling);
				case 'h2': break;
			}
		}
		return tables;
	}

	// Convert a table element into something easier to work with 
	function parseTable(table:htmlparser.HtmlNodeElement):Table{
		var tableRows = table.find('tr');
		var header = tableRows.shift();// remove first element

		if (header == null) {
			Console.warn('Table has no rows');
			return null;
		}

		return {
			columns: [
				for(child in header.children) child.innerText.toLowerCase()
			],
			rows: [
				for(row in tableRows) [
					for(child in row.children) child.innerText
				]
			]
		};
	}

	// Build a haxe type from the descriptors
	function generateHaxeType(type:PythonType, path:Array<String>, tables:Array<{columns:Array<String>, rows:Array<Array<String>>}>, ?doc:String):TypeDefinition {
		var fields = new Array<Field>();

		// Create fields from tables
		for(table in tables){
			switch table.columns {
				case ['methods' | 'class methods', 'return value', 'description']:
					for(row in table.rows){
						var methodDef = parseMethodDefinition(row[0]);
						if (methodDef == null) continue;

						fields.push({
							name: methodDef.name,
							doc: cleanDoc(row[2]),
							kind: FFun({args: methodDef.args, ret: parseType(row[1]), expr: null}),
							pos: nullPos,
							access: (table.columns[0] == 'class methods' || type == Module) ? [AStatic] : [],
						});
					}

				case ['constructors', 'description']:
					var row = table.rows[0];
					var methodDef = parseMethodDefinition(row[0]);
					fields.push({
						name: 'new',
						doc: cleanDoc(row[1]),
						kind: FFun({args: methodDef.args, ret: null, expr: null}),
						pos: nullPos
					});

				case ['properties', 'type', 'description']:
					for(row in table.rows){
						fields.push({
							name: row[0],
							doc: cleanDoc(row[2]),
							kind: FVar(parseType(row[1])),
							pos: nullPos,
							access: row[0] == 'class methods' ? [AStatic] : []
						});
					}

				case columns:
					Console.warn('Unknown table kind "$columns"');
			}
		}

		// No need to create a type for an empty python module
		if (type == Module && fields.length == 0){
			return null;
		}

		var haxeType = {
			pack: switch type {
				case Class: path.slice(0, path.length - 1);
				case Module: path;
			},
			kind: TDClass(null, null, false),
			isExtern: true,
			name: toClassNameCase(path[path.length-1]),
			meta: [{
				name: ':pythonImport',
				params: path.map(function(p) return macro '$p'),
				pos: nullPos
			}],
			fields: fields,
			pos: nullPos,
		}

		insertMissingFields(haxeType);

		return haxeType;
	}

	// The api docs miss out a few fields so they're hardcoded
	// Remove this if the API is updated
	function insertMissingFields(haxeType: TypeDefinition) {
		switch [haxeType.pack.join('.'), haxeType.name] {
			case ['sublime_plugin', 'WindowCommand']:
				haxeType.fields = (macro class X {
					var window: sublime.Window;
					function new(window: sublime.Window);
				}).fields.concat(haxeType.fields);
			case ['sublime_plugin', 'ViewEventListener'],
			     ['sublime_plugin', 'TextInputHandler']:
				haxeType.fields = (macro class X {
					var view: sublime.View;
					function new(view: sublime.View);
				}).fields.concat(haxeType.fields);
		}
	}

	function parseMethodDefinition(method:String): {
		name: String,
		args: Array<FunctionArg>
	} {
		// Example method
		// showQuickPanel(key, command, args, <displayArgs>, <flags>, <[example_array]>)
		var methodPattern = ~/(\w+)\(([^)]*)\)/;

		if (!methodPattern.match(method)){
			if (~/no\s+methods/igm.match(method)) {
				// valid null method
				return null;
			} else {
				// something weird - cannot parse
				throw 'Could not parse method definition "${method}"';
			}
		}

		var methodName = methodPattern.matched(1);
		var argDefs = methodPattern.matched(2).split(',').map(StringTools.trim).filter(function(str) return str.length > 0);

		// parse arguments
		var args = new Array<FunctionArg>();

		var argNamePattern = ~/(\[*)\s*(\w+)\s*(\]*)/g;
		var argIsOptionalPattern = ~/<[^>]+/g;
		for(argDef in argDefs) {
			if (!argNamePattern.match(argDef)) {
				throw 'Could not parse argument definition "$argDef"';
			}

			var name = argNamePattern.matched(2);
			var arrayOpen = argNamePattern.matched(1);
			var arrayClose = argNamePattern.matched(3);

			if (arrayOpen.length != arrayClose.length) {
				throw 'Unmatched square brackets when parsing argument "$argDef"';
			}

			var arrayDepth = arrayOpen.length;
			var optional = argIsOptionalPattern.match(argDef);
			var type = guessTypeFromName(name, methodName);
			// recursively wrap base type in Array<> for each array depth level
			for(i in 0...arrayDepth)
				type = macro :Array<$type>;

			args.push({
				name: cleanName(name),
				opt: optional,
				type: type
			});
		}

		return {
			name: methodName,
			args: args
		}
	}

	function parseType(typeString:String):ComplexType {
		// determine array depth
		var arrayDepth = 0;
		// if the type string is surrounded with square brackets then we count them to find the array depth
		// if it doesn't conform to this pattern (like "[str] or [(str,value)]"), then array depth is 0
		var arrayPattern = ~/^(\[*)([^\]]*)(\]*)$/;
		var arrayPatternMatched = arrayPattern.match(typeString);
		if (arrayPatternMatched) {
			if (arrayPattern.matched(1).length != arrayPattern.matched(3).length) {
				throw 'Unmatched square brackets when parsing type "$typeString"';
			}
			arrayDepth = arrayPattern.matched(1).length;
		}

		var typeInner = arrayPatternMatched ? arrayPattern.matched(2) : typeString;
		var type:ComplexType = null;

		// try parsing as a tuple (non-recursive)
		var tuplePattern = ~/^\(([\w\[\],\s]+)\)$/;
		var typeNamePattern = ~/^(\w+)$/;

		// because it's a pain to distinguish between commas in tuples and commas separating either types we forbid tuples in the comma separated list
		// in other words, TypeA, (TypeB, TypeC), TypeD is a pain in regex
		// could improve but it does not yet occur in the API
		var eitherPattern = ~/^((([^\s,()]+)(,\s)?)+)\sor\s([^\s]+)$/i;

		if (tuplePattern.match(typeInner)){
			var tupleParams = tuplePattern.matched(1).split(',').map(StringTools.trim).filter(function(str) return str.length > 0);
			var paramTypes = [
				for(param in tupleParams) parseType(param)
			];
			type = TPath({
				pack: ['python', 'Tuple'],
				name: 'Tuple' + paramTypes.length,
				params: [
					for(paramType in paramTypes) TPType(paramType)
				]
			});
		}
		else if(eitherPattern.match(typeInner)){
			// extract individual type strings from the list
			// split the comma separate type list
			var eitherStrings = eitherPattern.matched(1).split(',').map(function(s) return StringTools.trim(s).toLowerCase());
			// add final type (i.e. 'or Type')
			eitherStrings.push(eitherPattern.matched(5).toLowerCase());

			// parse types for each of the type strings in the list
			var eitherTypes = new Array<ComplexType>();
			for(str in eitherStrings) {
				if (str == 'none') continue; // skip 'none' type because this is handled separately
				var t = parseType(str);
				switch t {
					// if one of the types is unknown (i.e. Any), then don't bother with the :Either type
					case TPath({name: 'Any'}):
						type = macro :Any;
						break;
					default:
						eitherTypes.push(t);
				}
			}

			// Convert our types into :Either<T1, T2>
			if (type == null) {
				switch eitherTypes.length {
					case 1:
						type = eitherTypes[0];
					case 2:
						var t1 = eitherTypes[0];
						var t2 = eitherTypes[1];
						type = macro :haxe.extern.EitherType<$t1, $t2>;
					default:
						// We could in principle support this with nested eithers but at the moment there's no cases in the API that require this
						Console.warn('Cannot handle either-type with more than two types');
						type = macro :Any;
				}
			}

			// if one of the possible types is 'none' then wrap in Null<T> to document this
			if (type != null && eitherStrings.indexOf('none') != -1) {
				type = macro :Null<$type>;
			}
		}
		// parse as plain old type name
		else if(typeNamePattern.match(typeInner)){
			type = guessTypeFromName(typeNamePattern.matched(1));
		}

		if (type != null) {
			// recursively wrap base type in Array<> for each array depth level
			for(i in 0...arrayDepth)
				type = macro :Array<$type>;
			return type;
		} else {
			Console.warn('Cannot parse type "$typeString"');
			return macro :Any;
		}
	}

	function registerType(path:Array<String>, syntaxType:PythonType){
		switch syntaxType {
			case Class:
				classPathRegister.push(path);
			default:
		}
	}

	function guessTypeFromName(name:String, ?methodName:String):ComplexType {
		// hard coded edge cases where the same name is used with different types
		switch [name, methodName] {
			case ['locations', 'on_query_completions']:
				return macro :Array<Int>;
			default:
		}

		var plural = name.charAt(name.length - 1) == 's';
		// remove trailing s for plurals
		if (plural){
			name = name.substr(0, name.length - 1);
		}

		var nameLowerCase = name.toLowerCase();

		// look-up for common naming conventions
		switch nameLowerCase {
			case 'none': return macro :Void;
			case 'value': return macro :Any;
			case 'default': return macro :Any;
			case 'dip': return macro :Float;
			case 'point': return macro :Int;
			case 'int': return macro :Int;
			case 'byte': return macro :python.Bytes;
			case 'dict': return macro :python.Dict<String, Any>;
			case 'list': return macro :Array<Any>;
			case 'location': return macro: python.Tuple.Tuple3<String, String, python.Tuple.Tuple2<Int, Int>>;
			case 'vector': return macro: python.Tuple.Tuple2<Int, Int>;
			case 'tuple': return macro: python.Tuple<Any>; //@! needs review

			// "CommandInputHandler: a subclass of either TextInputHandler or ListInputHandler."
			case 'commandinputhandler': return macro: haxe.extern.EitherType<sublime_plugin.TextInputHandler, sublime_plugin.ListInputHandler>;

			// less-precise 
			case 'forward': return macro: Bool;
			case 'animate': return macro: Bool;
			case 'pretty': return macro: Bool;
			case 'modifying_only': return macro: Bool;
			case 'unlisted': return macro: Bool;
			case 'show_surround': return macro: Bool;
			case 'match_all': return macro: Bool;

			case 'group': return macro :Int;

			// don't like this one bit but it seems to be a convention in the API
			case 'a': return macro :Int;
			case 'b': return macro :Int;

			case 'separator': return macro: String;
			case 'selector': return macro: String;
			case 'scope': return macro: String;
			case 'format': return macro: String;
			case 'encoding': return macro: String;
			case 'content': return macro: String;
			case 'caption': return macro: String;
			case 'line_ending': return macro: String;
			case 'symbol': return macro: String;
			case 'syntax_file': return macro: String;
			case 'item': return macro: String;
			case 'icon': return macro: String;

			case 'variable': return macro :haxe.DynamicAccess<Any>;

			case 'data': return macro :python.Dict<String, Any>;

			// these would be better handled as enums but Int should do for now
			case 'classe': return macro :Int;
			case 'hover_zone': return macro :Int;
			case 'operator': return macro :Int;
			case 'layout': return macro :Int;

			default: null;
		}

		// matches the class name of a locally registered type
		for (path in classPathRegister) {
			var className = path[path.length - 1];
			var classNameLowerCase = className.toLowerCase();
			// remove plural s
			if (classNameLowerCase.charAt(classNameLowerCase.length - 1) == 's'){
				classNameLowerCase = classNameLowerCase.substr(0, classNameLowerCase.length - 1);
			}
			if (nameLowerCase == classNameLowerCase) {
				return TPath({
					pack: path.slice(0, path.length - 1),
					name: className
				});
			}
		}

		// ends in a string indicator
		if (~/(string|str|text|title|name|prefix|suffix|key)$/i.match(name)) {
			return macro :String;
		}

		// ends in an int indicator
		if (~/(idx|index|limit|timestamp|point|delay|row|col|width|height|depth)$/i.match(name) || (plural && ~/flag/i.match(name))) {
			return macro :Int;
		}

		// ends in a bool indicator
		if (~/(flag|bool|enabled)$/i.match(name)) {
			return macro :Bool;
		}

		// ends in a callback indicator
		if (~/(callback)$/i.match(name) || ~/(^on_)/i.match(name)) {
			return macro :?Any->Void;
		}

		// ends in a string map indicator
		if (~/(arg)$/i.match(name)) {
			return macro :python.Dict<String, Any>;
		}

		// ends in a regex indicator
		if (~/(pattern)$/i.match(name)) {
			return macro :EReg;
		}

		Console.warn('Cannot guess type for "$name"');

		return macro :Any;
	}

	function extractEnums(tables:Array<Table>){
		var enumPaths = new Array<String>();
		var enumPattern = ~/\b(\w+\.)+([A-Z_0-9]+)\b/g;

		for(table in tables){
			var descriptionIdx = table.columns.indexOf('description');
			if(descriptionIdx == -1){
				Console.warn('Could not find description column');
				continue;
			}

			for(row in table.rows){
				var description = row[descriptionIdx];
				var str = description;
				while(enumPattern.match(str)){
					enumPaths.push(enumPattern.matched(0));
					str = enumPattern.matchedRight();
				}
			}

		}
		return enumPaths;
	}

	function registerEnum(enumPath:String){
		if(enumRegister.indexOf(enumPath) == -1){
			enumRegister.push(enumPath);
		}
	}

	function deduplicateFields(type:TypeDefinition){
		var depulicatedFields = new Array<Field>();

		/*
		// Dedupe via rename and alias
		for(f1 in type.fields){
			var duplicateFields = type.fields.filter(function(f2) return (f2.name == f1.name) && (f1 != f2));
			if (duplicateFields.length > 0) {
				var nativeName = f1.name;
				f1.name = f1.name + (duplicateFields.length + 1);
				if (f1.meta == null) f1.meta = [];
				f1.meta.push({
					name: ':native',
					params: [macro '$nativeName'],
					pos: nullPos,
				});
			}
		}
		*/

		// Dedupe via @:overload metadata
		var i = type.fields.length - 1;
		while(i >= 0){
			var f1 = type.fields[i];
			var duplicateFields = type.fields.filter(function(f2) return (f2.name == f1.name) && (f1 != f2));
			if (duplicateFields.length > 0){
				// add an overload to the lowest-indexed matching field
				var mainField = duplicateFields[0];
				if (mainField.meta == null) mainField.meta = [];

				var fun:Function = switch f1.kind {
					case FFun(f): f;
					default: null;
				}

				fun.expr = macro {};

				mainField.meta.push({
					name: ":overload",
					params: [{
						expr:EFunction(null, fun),
						pos: nullPos
					}],
					pos: nullPos
				});

				// remove current field
				type.fields.splice(i, 1);
			}
			i--;
		}
	}

	inline function toClassNameCase(str:String) {
		return str.charAt(0).toUpperCase() + str.substr(1);
	}

	function cleanDoc(doc:String):String{
		//clean doc
		var trimmedLines = doc.split('\n').map(function(line) return StringTools.trim(line));
		var filteredLines = new Array<String>();
		var lastLineWasEmpty = false;
		for(line in trimmedLines){
			var lineEmpty = line == '';

			if (lineEmpty && lastLineWasEmpty) {
				// don't push
			} else {
				filteredLines.push(line);
			}

			lastLineWasEmpty = lineEmpty;
		}
		return StringTools.trim(filteredLines.join('\n'));
	}

	function cleanName(name:String){
		return disallowedNames.indexOf(name) != -1 ? '_$name' : name;
	}

	static var nullPos = { min:0, max:0, file:"" };
	static var disallowedNames = [
		'break',
		'case',
		'cast',
		'catch',
		'class',
		'continue',
		'default',
		'do',
		'dynamic',
		'else',
		'enum',
		'extends',
		'extern',
		'false',
		'for',
		'function',
		'if',
		'implements',
		'import',
		'in',
		'inline',
		'interface',
		'new',
		'null',
		'override',
		'package',
		'private',
		'public',
		'return',
		'static',
		'switch',
		'this',
		'throw',
		'true',
		'try',
		'typedef',
		'untyped',
		'using',
		'var',
		'while'
	];

	static function main() {
		// console setup
		Console.logPrefix = '<b><dim>    Log:<//> ';
		Console.warnPrefix = '<b><yellow>Warning:<//> ';
		Console.errorPrefix = '<b><red>  Error:</b> ';
		Console.successPrefix = '<b><light_green>Success:<//> ';
		new Main();
	}

}