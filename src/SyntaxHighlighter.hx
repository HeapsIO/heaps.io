import haxe.Json;
import highlighter.Highlighter;
import sys.io.File;

class SyntaxHighlighter
{
	public static function patch () {
		Sys.println("Applying syntax highlighting ...");

		var grammarFiles = [
			"haxe" => "grammars/haxe-TmLanguage/haxe.tmLanguage",
			"hxml" => "grammars/haxe-TmLanguage/hxml.tmLanguage",
			"html" => "grammars/html.tmbundle/Syntaxes/HTML.plist",
		];

		Highlighter.loadHighlighters(grammarFiles, function(highlighters) {
			// Go over the generated HTML file and apply syntax highlighting
			var missingGrammars = Highlighter.patchFolder("output/documentation", highlighters, function(classList) {
				return classList.substr(12);
			});

			for (g in missingGrammars) {
				Sys.println('Missing grammar for "${g}"');
			}

			// Go over the generated HTML file and apply syntax highlighting
			missingGrammars = Highlighter.patchFolder("output/samples", highlighters, function(classList) {
				return classList.substr(12);
			});

			for (g in missingGrammars) {
				Sys.println('Missing grammar for "${g}"');
			}

			// Add CSS rules for highlighting
			var path = "output/css/styles.min.css";
			var baseStyle = File.getContent(path);
			var syntaxStyle = highlighters["haxe"].runCss();
			File.saveContent(path, baseStyle + syntaxStyle);
		});
	}

	public static function main(){
		SyntaxHighlighter.patch();
	}
}
