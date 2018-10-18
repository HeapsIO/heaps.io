package;

import Utils.measure;

/**
 * @author Mark Knol
 */
class Main {

	public static function main() {
		var generator = new Generator();
		generator.titlePostFix = " - Heaps.io Game Engine";
		generator.basePath = "https://heaps.io/";
		generator.websiteRepositoryUrl = "https://github.com/HeapsIO/heaps.io/";
		generator.projectRepositoryUrl = "https://github.com/HeapsIO/heaps/";
		generator.repositoryBranch = "master";

		generator.build();
		
		
		generator.createRedirects([
			// add documentation landing redirect
			"documentation/index.html" => "/documentation/home.html",
			// overwrite readme to point to landing
			"documentation/readme.html" => "/documentation/home.html",
		]);
		
		measure("include assets", function() { 
			generator.includeDirectory("assets/includes");
		});
	}
}
