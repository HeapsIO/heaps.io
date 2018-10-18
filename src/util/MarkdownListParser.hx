package util;
import data.Category;
import data.Page;
import haxe.io.Path;
using StringTools;
/**
 * @author Mark Knol
 */
class MarkdownListParser {
	/**
	   Parses a _sidebar.md
	**/
	public static function parse(sidebar:String, basePath:String = ''):MDType {
		var lines:Array<String> = ~/(\r\n|\r)/g.replace(sidebar, '\n').split('\n');
		var prevIndent = 0;
		var toplevel = MDCategory('toplevel', '', [], null);
		var prevCategory:MDType = toplevel;
		var currentCategory:MDType = toplevel;
		var prevLink:MDType = toplevel;
		for (line in lines) {
			var listStartIndex = line.indexOf('*');
			if (listStartIndex != -1) {
				var indent:Int = Std.int(listStartIndex / 2); // 2-space indent;

				// Link is one of this:
				// * [[name]]
				// * [name](thing)
				// * plain
				var link = if (line.indexOf('[[') > -1) {
					var name = line.split('[[').pop().split(']]').shift();
					MDLink(name, basePath + name);
				} else if (line.indexOf('[') > -1 && line.indexOf('(') > -1) {
					var name = line.split('[').pop().split(']').shift();
					var path = line.split('(').pop().split(')').shift();
					MDLink(name, path);
				} else {
					var plain = line.substr(listStartIndex + 2);
					MDPlain(plain);
				}

				var current:MDType = null;
				if (indent > prevIndent ) {
					switch currentCategory {
						case MDCategory(cname, cpath, links, parent):
							switch prevLink {
								case MDLink(name, path):
									// remove old link as category
									links.remove(prevLink);
									// register new category
									currentCategory = MDCategory(name, path, [link], currentCategory);
									links.push(currentCategory);
									
								case _:
							}
						case _:
					}
					prevIndent = indent;
				} else {
					// TODO: support going back more than one indentation level
					if (indent < prevIndent) {
						for(i in 0...prevIndent-indent) { 
							currentCategory = switch(currentCategory) {
								case MDCategory(_, _, _, parent):
									parent;
								case _:
									null;
							};
						}
					}
					
					switch currentCategory {
						case MDCategory(_, _, links,_):
							links.push(link);
						case _:
					}
					prevIndent = indent;
					prevLink = link;
				}
			}
		}
		return toplevel;
	}

	public static function toHTML(type:MDType, activePath:String, pages:Array<Page>):StringBuf {
		function findName(name:String, path:String) {
			for (p in pages) {
				if (p.outputPath.file == new Path(path).file && p.title != null) {
					return p.title;
				}
			}
			return name;
		}
		var html = new StringBuf();
		switch (type) {
			case MDLink(name, path):
				var path = parsePath(path);
				var name = findName(name, path);
				var activeCssClass = if (activePath == path) ' class="active"' else '';
				var currentCssClass = if (activePath == path) ' class="current"' else '';
				html.add('<li$activeCssClass><a href="$path"$currentCssClass>$name</a></li>');

			case MDPlain(text):
				html.add('<li><span>$text</span></li>');

			case MDCategory(name, path, links, parent):
				var path = parsePath(path);
				var name = findName(name, path);
				if (name == 'toplevel') {
					html.add('<ul class="unstyled">');
				} else {
				var activeCssClass = if (activePath == path) ' class="active"' else '';
				var currentCssClass = if (activePath == path) ' class="current"' else '';
					html.add('<li$activeCssClass><a href="$path"$currentCssClass>$name</a><ul>');
				}

				for (link in links) {
					html.add(toHTML(link, activePath, pages).toString());
				}

				if (name == 'toplevel') {
					html.add('</ul>');
				} else {
					html.add('</ul></li>');
				}
		}
		return html;
	}

	public static function parsePath(path:String) {
		return path.toLowerCase().replace(' ', '-') + '.html';
	}
}

enum MDType {
	MDLink(name:String, path:String);
	MDPlain(text:String);
	MDCategory(name:String, path:String, links:Array<MDType>, parent:MDType);
}