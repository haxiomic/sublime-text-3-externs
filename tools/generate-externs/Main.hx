import haxe.io.Path;
import haxe.macro.Expr;
import scriptutils.Log;

@:enum
abstract PythonType(String) {
	var Module = 'module';
	var Class = 'class';
	@:from static inline function fromString(str:String):PythonType
		return untyped str.toLowerCase();
}

typedef Table = {
	columns: Array<String>,
	rows: Array<Array<String>>
}

class Main{

	var sublimeApiUrl = 'https://www.sublimetext.com/docs/3/api_reference.html';
	var downloadDir = 'download';
	var externDir = '../../externs';
	var titlePatern = ~/([\w.]+)\s+(Class|Module)/i;
	var titleTagName = 'h2';

	var classPathRegister = new Array<Array<String>>();
	var enumRegister = new Array<String>();

	function new(){
		var req = new haxe.Http(sublimeApiUrl);

		req.onData = function(content: String){
			// Save html to disk
			sys.FileSystem.createDirectory(downloadDir);
			sys.io.File.saveContent(haxe.io.Path.join([downloadDir, 'api-reference.html']), content);

			processAPIDocs(content);
		}

		req.request();
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
				Log.warn('Ignoring title "${titleText}"');
				continue;
			}

			sections.push({
				syntaxType: titlePatern.matched(2),
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
				Log.warn('Could not find class for enum "$enumPath"');
			}

			matchingTypes[0].fields.push({
				name: parts[parts.length - 1],
				access: [AStatic],
				kind: FVar(macro :Int),
				pos: nullPos
			});
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
			Log.success('Saved ${savePath}');
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
			Log.warn('Table has no rows');
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
							access: row[0] == 'class methods' ? [AStatic] : [],
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
							pos: nullPos
						});
					}

				case columns:
					Log.warn('Unknown table kind "$columns"');
			}
		}

		// No need to create a type for an empty python module
		if (type == Module && fields.length == 0){
			return null;
		}

		return {
			pack: switch type {
				case Class: path.slice(0, path.length - 1);
				case Module: path;
			},
			kind: TDClass(null, null, false),
			isExtern: true,
			name: toClassNameCase(path[path.length-1]),
			meta: type == Class ? [{
				name: ':pythonImport',
				params: path.map(function(p) return {expr: EConst(CString(p)), pos: nullPos}),
				pos: nullPos
			}] : [],
			fields: fields,
			pos: nullPos,
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

		var name = methodPattern.matched(1);
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
			var type = guessTypeFromName(name);
			// recursively wrap base type in Array<> for each array depth level
			for(i in 0...arrayDepth)
				type = macro :Array<$type>;

			args.push({
				name: name,
				opt: optional,
				type: type
			});
		}

		return {
			name: name,
			args: args
		}
	}

	function parseType(typeString:String):ComplexType {
		// determine array depth
		var arrayPattern = ~/^(\[*)([^\]]*)(\]*)$/;
		arrayPattern.match(typeString);
		var arrayDepth = arrayPattern.matched(1).length;
		if (arrayDepth != arrayPattern.matched(3).length) {
			throw 'Unmatched square brackets when parsing type "$typeString"';
		}

		var typeInner = arrayPattern.matched(2);
		var type:ComplexType = null;

		// try parsing as a tuple (non-recursive)
		var tuplePattern = ~/^\(([\w\[\],\s]+)\)$/;
		var typeNamePattern = ~/^(\w+)$/;
		var eitherPatern = ~/((\w+)\s*,\s*)*(\w+)\s+or\s+(\w+)/i;

		if (tuplePattern.match(typeInner)){
			var tupleParams = tuplePattern.matched(1).split(',').map(StringTools.trim).filter(function(str) return str.length > 0);
			var paramTypes = [
				for(param in tupleParams) parseType(param)
			];
			type = TPath({
				pack: ['python'],
				name: 'Tuple',
				params: [
					for(paramType in paramTypes) TPType(paramType)
				]
			});
		}
		else if(eitherPatern.match(typeInner)){
			var eitherStrings = Lambda.array(Lambda.flatMap(typeInner.split(','), function(x){
				return x.split('or');
			}).map(StringTools.trim)).map(function(s) return s.toLowerCase());

			type = switch (eitherStrings) {
				// Special case of Null<T>
				case [str, 'none'], ['none', str]:
					var t = guessTypeFromName(str); macro :Null<$t>; 
				default: null;
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
			Log.warn('Cannot parse type "$typeString"');
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

	function guessTypeFromName(name:String):ComplexType {
		// remove trailing s for plurals
		if (name.charAt(name.length - 1) == 's'){
			name = name.substr(0, name.length - 1);
		}

		var nameLowerCase = name.toLowerCase();

		// look-up for common naming conventions
		switch nameLowerCase {
			case 'none': return macro :Void;
			case 'value': return macro :Any;
			case 'default': return macro :Any;
			case 'dip': return macro :Float;
			case 'int': return macro :Int;
			case 'byte': return macro :python.Bytes;
			case 'dict': return macro :python.Dict;
			case 'list': return macro :List<Any>; //@! needs review
			case 'location': return macro: python.Tuple<String, String, python.Tuple<Int, Int>>;
			case 'vector': return macro: python.Tuple<Int, Int>;
			case 'tuple': return macro: python.Tuple<Any>;

			// less-precise 
			case 'forward': return macro: Bool;
			case 'animate': return macro: Bool;
			case 'pretty': return macro: Bool;
			case 'modifying_only': return macro: Bool;
			case 'unlisted': return macro: Bool;
			case 'show_surround': return macro: Bool;
			case 'match_all': return macro: Bool;

			case 'group': return macro :Int;

			// don't like this one bit
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

			case 'data': return macro :python.Dict;

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
		if (~/(idx|index|limit|timestamp|point|delay|row|col|flags|width|height|depth)$/i.match(name)) {
			return macro :String;
		}

		// ends in a bool indicator
		if (~/(flag|bool|enabled)$/i.match(name)) {
			return macro :Bool;
		}

		// ends in a callback indicator
		if (~/(callback)$/i.match(name) || ~/(^on)/i.match(name)) {
			return macro :Any->Void;
		}

		// ends in a string map indicator
		if (~/(arg)$/i.match(name)) {
			return macro :haxe.DynamicAccess<Any>;
		}

		// ends in a regex indicator
		if (~/(pattern)$/i.match(name)) {
			return macro :EReg;
		}

		Log.warn('Cannot guess type for "$name"');

		return macro :Any;
	}

	function extractEnums(tables:Array<Table>){
		var enumPaths = new Array<String>();
		var enumPattern = ~/(\w+\.)+([A-Z_0-9]+)/g;

		for(table in tables){
			var descriptionIdx = table.columns.indexOf('description');
			if(descriptionIdx == -1){
				Log.warn('Could not find description column');
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

	static var nullPos = { min:0, max:0, file:"" };
	static function main() new Main();

}