package;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
using StringTools;
/**
 * @author Mark Knol
 */
class GetWiki {
	static var GIT_REPO = "https://github.com/HeapsIO/heaps.wiki.git";
	static var FOLDER = ".temp-docs/";

	static function main() {
		var sampleDir = FOLDER + "samples/";
		var sampleBuildDir = sampleDir + "/build/";
		trace( "** Download the wiki");
		Sys.command('git', ["clone", "--depth", "1", "--single-branch", GIT_REPO, FOLDER]);
		trace( "** Download wiki complete");
	}

	static function runCommand(cmd:String, ?args:Array<String>):String {
		var p = new Process(cmd, args);
		var out:String = p.stdout.readAll().toString();
		p.close();
		//File.saveContent(TEMPFILE, out);
		return out;
	}

	static function copyDirectory(dir:String, path:String, recursive:Bool, onEachFile:String->String->Void) {
		FileSystem.createDirectory(path);
		trace("include directory: " + path);

		for (file in FileSystem.readDirectory(dir)) {
			var srcPath = '$dir/$file';
			var dstPath = '$path/$file';
			if (FileSystem.isDirectory(srcPath)) {
				if (recursive) {
					FileSystem.createDirectory(dstPath);
					copyDirectory(srcPath, dstPath, recursive, onEachFile);
				}
			} else {
				onEachFile(srcPath, dstPath);
			}
		}
	}
}
