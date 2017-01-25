package;
/**
 * @author Mark Knol
 */
class Main {

	public static function main() {
		
      var generator = new Generator();
      generator.titlePostFix = " - Heaps.io Game Engine";
      generator.basePath = "http://heaps.io/";
      generator.repositoryUrl = "https://github.com/ncannasse/heaps/";
      generator.repositoryBranch = "master";
    
      generator.build();
      generator.includeDirectory("assets/includes");
	}
}
