package;
/**
 * @author Mark Knol
 */
class Main {

	public static function main() {
		
      var generator = new Generator();
      generator.titlePostFix = " - Heaps.io Game Engine";
      generator.basePath = "http://heaps.io/";
      generator.websiteRepositoryUrl = "https://github.com/HeapsIO/heaps.io/";
      generator.projectRepositoryUrl = "https://github.com/HeapsIO/heaps/";
      generator.repositoryBranch = "master";
    
      generator.build();
      generator.includeDirectory("assets/includes");
	}
}
