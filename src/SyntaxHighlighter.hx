import haxe.Json;
import highlighter.Highlighter;
import sys.io.File;

class SyntaxHighlighter
{
	public static function patch () {
		Sys.println("Applying syntax highlighting ...");

		var haxeGrammar = new Highlighter("grammars/haxe-TmLanguage/haxe.tmLanguage");
		var hxmlGrammar = new Highlighter("grammars/haxe-TmLanguage/hxml.tmLanguage");
		var htmlGrammar = new Highlighter("grammars/html.tmbundle/Syntaxes/HTML.plist");

		var grammars = [
			"haxe" => haxeGrammar,
			"hxml" => hxmlGrammar,
			"html" => htmlGrammar,
		];

		// Go over the generated HTML file and apply syntax highlighting
		var missingGrammars = Highlighter.patchFolder("output/documentation", grammars, function (classList) {
			return classList.substr(12);
		});

		for (g in missingGrammars) {
			Sys.println('Missing grammar for "${g}"');
		}

		// Go over the generated HTML file and apply syntax highlighting
		missingGrammars = Highlighter.patchFolder("output/samples", grammars, function (classList) {
			return classList.substr(12);
		});

		for (g in missingGrammars) {
			Sys.println('Missing grammar for "${g}"');
		}


		// Add CSS rules for highlighting
		var path = "output/css/styles.min.css";
		var baseStyle = File.getContent(path);
		var syntaxStyle = haxeGrammar.runCss();
		File.saveContent(path, baseStyle + syntaxStyle);
	}

	public static function main(){
		SyntaxHighlighter.patch();
	}
}
