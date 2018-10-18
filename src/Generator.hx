package;

import data.Category;
import data.Page;
import haxe.EnumTools;
import haxe.Http;
import haxe.Json;
import haxe.Timer;
import haxe.ds.StringMap;
import haxe.io.Path;
import markdown.AST.ElementNode;
import sys.FileSystem;
import sys.io.File;
import templo.Template;
import util.MarkdownListParser;
import Utils.measure;

using StringTools;

/**
 * @author Mark Knol
 */
class Generator {
	public var contentPath = "./assets/content/";
	public var outputPath = "./output/";
	public var websiteRepositoryUrl = "";
	public var projectRepositoryUrl = "";
	public var repositoryBranch = "";
	public var basePath = "";
	public var titlePostFix = "";
	public var samplesFolder = "assets/includes/samples/";
	public var documentationFolder = ".temp-docs/";
	public var assetsFolderName = "assets";

	private var _pages:Array<Page> = new Array<Page>();
	private var _templates:StringMap<Template> = new StringMap<Template>();

	public function new() { }

	/**
	 * Build the website.
	 * @param doMinify minifies the HTML output.
	 */
	public function build (doMinify:Bool = false) {
		//Utils.deleteRecursive(outputPath);
		initTemplate();

		// add pages
		measure("Documentation pages", function() { 
			addDocumentationPages(documentationFolder);
		});
		
		measure("General pages", function() { 
			addGeneralPages();
		});
		
		measure("Documentation pages", function() { 
			addSamplesPages(samplesFolder);
		});

		measure("Generating pages", function() {
			// generated pages
			for (page in _pages) {
				// set the data for the page
				var data = {
					title: '${page.title} $titlePostFix',
					now: Date.now(),
					pages: _pages,
					currentPage: page,
					basePath: basePath,
					pageContent: null,
					DateTools: DateTools,
					websiteRepositoryUrl:websiteRepositoryUrl,
					projectRepositoryUrl:projectRepositoryUrl,
					isSection: page.isSection,
				}
				if (page.contentPath != null) {
					page.addLinkUrl = getAddLinkUrl(page);
					data.pageContent = page.pageContent != null ? page.pageContent : getContent(contentPath + page.contentPath, data);
				}

				// execute the template
				var templatePath = contentPath + page.templatePath;
				if (!_templates.exists(templatePath)) {
					_templates.set(templatePath, Template.fromFile(templatePath));
				}
				var template = _templates.get(templatePath);

				var html = util.Minifier.removeComments(template.execute(data));

				if (doMinify) {
					// strip crap
					var length = html.length;
					html = util.Minifier.minify(html);
					var newLength = html.length;
					//trace("optimized " + (Std.int(100 / length * (length - newLength) * 100) / 100) + "%");
				}

				// make output directory if needed
				var targetDirectory = Path.directory(outputPath + page.outputPath);
				if (!FileSystem.exists(targetDirectory)) {
					FileSystem.createDirectory(targetDirectory);
				}

				// write output to file
				Sys.println("Created: " + outputPath + page.outputPath);
				File.saveContent(outputPath + page.outputPath, html);
			}
		});
		Sys.println(_pages.length + " pages done!");
	}
	
	public function createRedirects(redirects:Map<String, String>) {
		for(key in redirects.keys()) {
			var from = key;
			var to = redirects[key];
			Sys.println('Redirect: "$from" to "$to"');
			FileSystem.createDirectory(Path.directory(outputPath + from));
			File.saveContent(outputPath + from, '<script>window.location.href="$to";</script><noscript><meta http-equiv="refresh" content="0; url=$to"></noscript>');
		}
	}

	private function addPage(page:Page) {
		_pages.push(page);

		page.absoluteUrl = getAbsoluteUrl(page);
		page.baseHref = getBaseHref(page);

		if (page.contentPath != null) {
			page.contributionUrl = getContributionUrl(page);
			page.editUrl = getEditUrl(page);
		}
	}
	
	private function addGeneralPages() {
		var homePage = new Page("home", "layout-page-main.mtt", "index.mtt", "index.html")
			.hidden()
			.setTitle("Heaps - Haxe Game Engine")
			.setDescription('Cross platform graphics for high performance games.');

		var json: { web:Array<GameDef>, steam:Array<GameDef>} = Json.parse(File.getContent("assets/content/showcase/showcase.json"));
		var aboutPage = new Page("about", "layout-page.mtt", "about.mtt", "about.html")
			.hidden()
			.setCustomData({
				games: json
			})
			.setTitle("About - Haxe game enine")
			.setDescription('Heaps.io delivers fast iterations, real development power and multi-platform compilation with native access and minimal overhead. The toolkit is versatile, open-source and completely free.');

		var errorPage = new Page("error", "layout-page-main.mtt", "404.mtt", "404.html")
			.hidden()
			.setTitle("Page not found");

		addPage(homePage);
		addPage(aboutPage);
		addPage(errorPage);

		errorPage.baseHref = "/";
	}

	private function addDocumentationPages(documentationPath:String) {
		var pages:Array<Page> = [];
		for (file in FileSystem.readDirectory(documentationPath)) {
			var outputPathReplace = 'documentation/';
			if (file.startsWith("_") || Path.extension(file) != "md") continue; // filter
			else if (!FileSystem.isDirectory(documentationPath + file)) {
				var pageOutputPath = documentationPath.replace(documentationFolder, outputPathReplace);
				
				pageOutputPath = pageOutputPath.toLowerCase().replace(" ", "-") + getWithoutExtension(file).toLowerCase() + ".html";
				pages.push(new Page("documentation", "layout-page-documentation.mtt", documentationPath + file, pageOutputPath)
					.setCustomData({
						markdownPath: file,
					}));
			}
		}
		
		var sidebar = MarkdownListParser.parse(File.getContent(documentationPath + "_Sidebar.md"),  "documentation/");
		
		// render the markdown of the pages
		for (page in pages) {
			page.pageContent = parseMarkdownContent(page, page.contentPath.toString());
			addPage(page);
		}
		
		// add sitebar to pages
		for (page in pages) {
			var sidebarHTML:String = MarkdownListParser.toHTML(sidebar, page.outputPath.toString(), pages).toString();
			page.customData.sidebar = sidebarHTML;
			// no heading found in page
			if (page.title == null) {
				page.title = page.contentPath.file.replace("-", " ");
			}
		}
	}

	private function addSamplesPages(samplesPath:String) {
		var prev:Page = null;
		var samples:Array<Page> = [];

		var data: { samples:Array< { name:String, description:String}> } = Json.parse(File.getContent(contentPath + "samples/samples.json"));

		for (sample in data.samples) {
			var outFolder = 'samples/';
			var sampleName = sample.name;
			var sampleFolderName = sampleName.substr(0, 1).toLowerCase() + sampleName.substr(1); // starts with lowercase
			var pageOutputPath = sampleName.toLowerCase().replace(" ", "-").toLowerCase() + ".html";
			var page = new Page("samples", "layout-page-samples.mtt", samplesPath + sampleName, '$outFolder$pageOutputPath')
				.setTitle(sampleName)
				.setDescription('Heaps $sampleName example with source and live demo')
				.setCustomData({
					source: getContent(samplesPath + sampleName + ".hx", null).replace("\t", "  ").replace("<", "&lt;").replace(">","&gt;"),
					samplePath: '$outFolder' + sampleFolderName + "/",
					sampleName: sampleFolderName,
					prev: prev,
					samples: samples,
				});
			var markdown  = new Markdown.Document();
			page.pageContent =  Markdown.renderHtml(markdown.parseInline(sample.description));
			if (prev != null) prev.customData.next = page;

			addPage(page);
			samples.push(page);
			prev = page;
		}

		var page = new Page("samples", "layout-page.mtt", "samples.mtt", "samples/index.html")
			.setTitle("Examples overviews")
			.setDescription('Heaps examples overview with source and live demo')
			.setCustomData({samples:data})
			.hidden();
			
		addPage(page);
	}

	private function replaceTryHaxeTags(content:String) {
		//[tryhaxe](http://try.haxe.org/embed/ae6ef)
		return	~/(\[tryhaxe\])(\()(.+?)(\))/g.replace(content, '<iframe src="$3" class="try-haxe"><a href="$3">Try Haxe!</a></iframe>');
	}
	
	private function replaceWikiLinks(content:String) {
		// replace [[Page Name]] to <a href="documentation/page-name.html">Page Name</a>
		content = ~/\[\[(.+?)\]\]/g.map(content, function(ereg:EReg) {
			// trace("replaced link1:" + ereg.matched(1));
			var path = ereg.matched(1).replace(" ", "-").toLowerCase() + ".html";
			return '<a href="documentation/$path">${ereg.matched(1)}</a>';
		});
		
		// replace [home page](http://github.com/heapsio/heaps/wiki/home) to <a href="documentation/home.html">home page</a>
		return ~/\[(.+?)\]\(https:\/\/github.com\/(.+?)\/wiki\/(.+?)\)/g.map(content, function(ereg:EReg) {
			// trace("replaced link2:" + ereg.matched(3) + " named:" + ereg.matched(1));
			return '<a href="documentation/${ereg.matched(3).toLowerCase()}.html">${ereg.matched(1)}</a>';
		});
	}

	private function replaceYoutubeTags(content:String) {
		//[youtube](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
		return	~/(\[youtube\])(\()(.+?)(\))/g.replace(content, '<div class="flex-video widescreen"><iframe src="$3" frameborder="0" allowfullscreen=""></iframe></div>');
	}

	private function getBaseHref(page:Page) {
		if (page.outputPath.file == "404.html") {
			return basePath;
		}
		var href = [for (s in page.outputPath.toString().split("/")) ".."];
		href[0] = ".";
		return href.join("/");
	}

	public inline function getEditUrl(page:Page) {
		return '${websiteRepositoryUrl}edit/${repositoryBranch}/${contentPath}${page.contentPath}';
	}

	public inline function getContributionUrl(page:Page) {
		return '${websiteRepositoryUrl}tree/${repositoryBranch}/${contentPath}${page.contentPath}';
	}

	public function getAddLinkUrl(category:Category = null, page:Page = null) {
		var fileNameHint = "/page-name.md/?filename=page-name.md";
		var directory = if (category != null) {
			category.pages[0].contentPath.dir;
		} else {
			page.contentPath.dir;
		}
		return '${websiteRepositoryUrl}new/master/${contentPath}${directory}${fileNameHint}';
	}

	public inline function getAbsoluteUrl(page:Page) {
		return basePath + page.outputPath.toString();
	}

	private static inline function getWithoutExtension(file:String) {
		return Path.withoutDirectory(Path.withoutExtension(file));
	}

	private function getContent(file:String, data:Dynamic) {
		return switch (Path.extension(file)) {
			case "md":
				parseMarkdownContent(null, file);
			case "mtt":
				Template.fromFile(file).execute(data);
			default:
				File.getContent(file);
		}
	}

	public function parseMarkdownContent(page:Page, file:String):String {
		var document:Markdown.Document = new Markdown.Document();
		var markdown = File.getContent(file);
		markdown = replaceYoutubeTags(markdown);
		markdown = replaceTryHaxeTags(markdown);
		markdown = replaceWikiLinks(markdown);

		try {
			// replace windows line endings with unix, and split
			var lines = ~/(\r\n|\r)/g.replace(markdown, '\n').split("\n");

			// parse ref links
			document.parseRefLinks(lines);

			// parse ast
			var blocks = document.parseLines(lines);
			// pick first header, use it as title for the page
			var titleBlock = null;
			if (page != null) {
				var hasTitle = false;
				for (block in blocks) {
					var el = Std.instance(block, ElementNode);
					if (el != null) {
						if (!hasTitle && el.tag == "h1" && !el.isEmpty()) {
							page.title = new markdown.HtmlRenderer().render(el.children);
							hasTitle = true;
							titleBlock = block;
							continue;
						}
						if (hasTitle && el.tag != "pre" && page.description == null) {
							var description = new markdown.HtmlRenderer().render(el.children);
							page.description = new EReg("<(.*?)>", "g").replace(description, "").replace('"', "").replace('\n', " ");
							break;
						}
					}
				}
			}
			if (titleBlock != null) blocks.remove(titleBlock);

			return Markdown.renderHtml(blocks);
		} catch (e:Dynamic) {
			return '<pre>$e</pre>';
		}
	}

	public function includeDirectory(dir:String, ?path:String) {
		if (dir.indexOf(".vscode") != -1) return;
			
		if (path == null) path = outputPath;
		else FileSystem.createDirectory(path);
		Sys.println("include directory: " + path);

		for (file in FileSystem.readDirectory(dir)) {
			var srcPath = Path.normalize('$dir/$file');
			var dstPath = Path.normalize('$path/$file');
			
			if (FileSystem.isDirectory(srcPath)) {
				FileSystem.createDirectory(dstPath);
				includeDirectory(srcPath, dstPath);
			} else {
				if (FileSystem.exists(dstPath)) {
					var statFrom = FileSystem.stat(srcPath);
					var statTo = FileSystem.stat(dstPath);
					if (statFrom.mtime.getTime() < statTo.mtime.getTime()) {
						// only copy files with newer modified time
						continue;
					}
				}
				File.copy(srcPath, dstPath);
			}
		}
	}

	private function initTemplate() {
		// for some reason this is needed, otherwise templates doesn't work.
		// the function fails, but i think internally Template can resolve paths now.
		try {
			Template.fromFile(contentPath + "layout-main.mtt").execute({});
		} catch (e:Dynamic) { }
	}

	static inline private function min(a:Int, b:Int) return Std.int(Math.min(a, b));
}

typedef GameDef = {
	image: String, 
	title: String, 
	author:String, 
	url: String,
}
