package data;

import data.Category;
import haxe.io.Path;

/**
 * @author Mark Knol
 */
class Page {
	public var visible:Bool = true;
	public var title:String;
	public var description:String;
	public var templatePath:Path;
	public var contentPath:Path;
	public var outputPath:Path;
	public var customData:Dynamic = {};
	public var absoluteUrl:String;
	public var editUrl:String;
	public var addLinkUrl:String;
	public var contributionUrl:String;
	public var baseHref:String;
	public var section:String;

	//only available in series
	public var next:Page;
	public var prev:Page;

	public var pageContent:String;

	public function new(section:String, templatePath:String, contentPath:String, outputPath:String) {
		this.section = section;
		this.templatePath = new Path(templatePath);
		this.contentPath = contentPath != null ? new Path(contentPath) : null;
		this.outputPath = outputPath != null ? new Path(outputPath) : null;
	}

	public function setCustomData(data:Dynamic):Page {
		this.customData = data;
		return this;
	}

	public function setTitle(title:String):Page {
		this.title = title;
		return this;
	}

	public function setDescription(description:String):Page {
		this.description = description;
		return this;
	}
	
	public function isSection(value:String):Bool {
		return section == value;
	}

	public function hidden() {
		visible = false;
		return this;
	}
}
