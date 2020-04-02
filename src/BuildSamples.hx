package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import Utils.measure;
using StringTools;

/**
 * @author Mark Knol
 */
class BuildSamples {
	static var GIT_TAG = "1.7.0"; // tag name
	static var GIT_REPO = "https://github.com/HeapsIO/heaps.git";
	static var FOLDER = ".temp/";

	static function main() {
		var sampleDir = FOLDER + "samples/";
		var sampleBuildDir = sampleDir + "/build/";

		measure("Download samples from git", function() {
			Sys.command('git', ["clone", "--branch",  GIT_TAG, "--depth", "1", "--single-branch", GIT_REPO, FOLDER]);
		});

		measure("Compile samples", function() {
			Sys.setCwd(sampleDir);
			Sys.command('haxe', ["all.hxml"]);
		});

		Sys.setCwd("../../");
		trace(sampleBuildDir, "assets/includes/samples/");
		measure("Copy + minify samples", function() {
			copyDirectory(sampleBuildDir, "assets/includes/samples/", true, function(srcPath, dstPath) {
				if (new Path(srcPath).file.startsWith(".")) return;

				File.copy(srcPath, dstPath);
				if (dstPath.endsWith(".js")) {
					trace("Minify " + dstPath);
					UglifyJS.compileFile(dstPath, dstPath);
				}
			});
		});

		measure("Copy sample source files", function() {
			copyDirectory(sampleDir, "assets/includes/samples/", false, function(srcPath, dstPath) {
				if (dstPath.indexOf(".hx") != -1) {
					trace("Copy source file: " + dstPath);
					File.copy(srcPath, dstPath);
				}
			});
		});
	}

	static function runCommand(cmd:String, ?args:Array<String>):String {
		var p = new Process(cmd, args);
		var out:String = p.stdout.readAll().toString();
		p.close();
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
