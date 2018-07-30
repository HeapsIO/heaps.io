class LimeApp extends lime.app.Application {
	override public function create(c) {
		super.create(c);
		@:privateAccess Base2D.main();
	}
}
