//Used to extract a rough class from http://www.sublimetext.com/docs/3/api_reference.html
// Pull in jquery for lazyness
function get$(callback){
    if(window.jQuery){
        if(callback) callback(window.jQuery);
        return window.jQuery;
    }
    var script = document.createElement("script");
    script.src = 'https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js';
    script.onload = function(){
        callback(window.jQuery);
    }
    document.getElementsByTagName("head")[0].appendChild(script);
}

function haxeType(pythonType){
    var pythonTypeReduced = pythonType.toLowerCase().trim();
    switch(pythonTypeReduced){
        case 'int': return 'Int';
        case 'real': return 'Float';
        case 'string': return 'String';
        case 'bool': return 'Bool';
        case 'none': return 'Void';
    }

    //array type
    var result;
    var arrayTypeReg = /\[\s*(\w+)\s*\]/;
    if(result = arrayTypeReg.exec(pythonTypeReduced)){
        //make first char uppercase
        var arrayType = result[1][0].toUpperCase()+result[1].substring(1);
        return 'Array<'+arrayType+'>';
    }
    //class type
    var classTypeReg = /^\s*(\w+)\s*$/;
    if(result = classTypeReg.exec(pythonTypeReduced)){
        var classType = result[1][0].toUpperCase()+result[1].substring(1);
        return classType;
    }

    //@todo: handle tuples
    console.warn('cannot deal with pythonType \''+pythonType+'\'');
    return 'Dynamic';
}

function haxeFuncDef(pythonFunDef){
    return {
        name: pythonFunDef.name,
        arguments: haxeArgs(pythonFunDef.arguments),
        returnType: haxeType(pythonFunDef.returnType),
        description: pythonFunDef.description,
        isPublic: pythonFunDef.isPublic,
        isStatic: pythonFunDef.isStatic,
    }
}

function haxeArgs(pythonArguments){//@todo types shouldn't exclude one another
    var converted = [];
    for(i in pythonArguments){
        var pa = pythonArguments[i].trim();

        var result;
        //plain
        var plainReg = /^\s*(\w+)\s*$/;
        if(result = plainReg.exec(pa)){
            converted[i] = result[1];
            continue;
        }
        //optional
        var optionalReg = /(?:<|>)\s*(\w+)\s*(?:>|<)/igm;
        if(result = optionalReg.exec(pa)){
            converted[i] = '?'+result[1];
            continue;
        }
        //array
        var arrayReg = /\[\s*(\w+)\s*\]/;
        if(result = arrayReg.exec(pa)){
            converted[i] = result[1]+':Array<Dynamic>';
            continue;
        }

        console.warn('cannot deal with argument \''+pa+'\'');
        converted[i] = pa;
    }
    return converted;
}

//printing
function haxeArgString(haxeArguments){
    if(!haxeArguments) return '';
    return haxeArguments.length > 0 ? haxeArguments.join(', ') : '';
}

function haxeFuncString(haxeFuncDef){
    var multilineDescription = haxeFuncDef.description.match((/(\r\n|\n|\r)/igm)) !== null;

    return (multilineDescription ? '/* ' : '// ') + haxeFuncDef.description + (multilineDescription ? ' */' : '')
        + '\n'
        + [
            (haxeFuncDef.isStatic ? 'static' : ''),
            (haxeFuncDef.isPublic ? 'public' : ''), 
            'function',
            haxeFuncDef.name + '('+haxeArgString(haxeFuncDef.arguments)+')',
            ':',
            haxeFuncDef.returnType
        ].join(' ').trim()
        + ';';
}

function generateStubsFromTable(table){
    var pythonDefinitions = [];

    table = $(table);
    table.find('tr').each(function(i, tr){
        tr = $(tr);
        x = tr;
        //make sure it's a valid row
        var mth = tr.children('.mth');
        var rtn = tr.children('.rtn');
        var dsc = tr.children('.dsc');//optional
        if(mth.length <= 0 || rtn.length <= 0) return;
        
        //extract raw function name and arguments
        var funcReg = /([\w]+)\s*\(([^\)]*)\)/igm;
        var result = funcReg.exec(mth.text());
        var name = result[1];
        var arguments = result[2].length > 0 ? result[2].replace(/\s/g, '').split(',') : null;//remove whitespace
        var returnType = rtn.text().trim();
        var description = dsc.text().trim().length > 0 ? dsc.text().trim() : null;

        pythonDefinitions.push({
            name: name,
            arguments: arguments,
            returnType: returnType,
            description: description,
            isPublic: true,
            isStatic: false,
        });
    });

    //convert to haxe definition
    var stubsStrings = [];
    for(i in pythonDefinitions){
        var hd = haxeFuncDef(pythonDefinitions[i]);
        stubsStrings.push(haxeFuncString(hd));
    }

    var stubsString = stubsStrings.join('\n');
    return stubsString;
}

function generateClass(name){
    var table = $("h2:contains("+name+")").nextAll('table')[0];
    var stubs = generateStubsFromTable(table);
    return [
            'extern',
            'class',
            name
        ].join(' ').trim()
        + '{\n'
        + stubs
        + '\n'
        + '}'
}

//start
//externs for sublime.View
get$(function(){
    console.log(generateClass('Selection'));
});