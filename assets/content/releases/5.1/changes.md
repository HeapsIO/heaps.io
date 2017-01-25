## Release notes 

This is the first HaxeDevelop distro build. 

##### List of changes

* Added support for AIR/FP 20 and 21
* More info is now shown in the status bar
* Added mouse wheel support to window list menu
* Word highlight color added to the editor dialog
* [Dialog for move refactoring](https://cloud.githubusercontent.com/assets/1700940/12003384/50c11744-ab2d-11e5-9094-60804182dc4c.gif) added
* Rename project from ProjectManager added
* Include available refactor menus in code generation list
* Less aggressive completion code reformatter
* Sort imports by package then by name
* Store watch expressions between FD sessions
* Lots of new theme settings added and theming fixes and improvements
* Improved detection and handling of different 8-bit encodings
* Remove selection and highlights when text is cleared in QuickFind
* StartPage lost reference to DockPanel on layout restore fixed
* Added BaseDir to BuildEventVars and fixed FDBuild and ToolsDir paths
* Fixed `$(FDBuild)` and `$(ToolsDir)` showing wrong values in project properties dialog
* Support for hotkeys added for converting to uppercase and lowercase in rename form
* Find and replace in document dialog is now resizable
* _Control+F_ now focuses find in find and replace dialogs
* 64-bit version of FlashDevelop added [experimental]
* Added _.flump_ as json file extension
* Added _.resx_ as xml file extension
* Caret policy changed for better position control
* Delayed FlashConnect and project manager focused on first run
* Debugger panels are now docked together on first run
* More Results panel shortcuts added
* Greatly improved shortcut dialog
* Fixed interface detection inside SWC files
* Haxe and AS3 parsing changes, autocompletion should be better in several cases
* Fixes for several common edge cases in code generation
* Fixed interface implementation for Haxe
* Change Haxe search URL to new API location
* Haxe Java/C# templates added
* Korean translation added

.. and lots of optimizations, other fixes and minor improvements