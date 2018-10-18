package;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import Utils.measure;
using StringTools;

/**
 * @author Mark Knol
 */
class GetWiki {
	static var GIT_REPO = "https://github.com/HeapsIO/heaps.wiki.git";
	static var FOLDER = ".temp-docs/";

	static function main() {
		measure("Download wiki from git", function() {
			Sys.command('git', ["clone", "--depth", "1", "--single-branch", GIT_REPO, FOLDER]);
		});
	}
}
