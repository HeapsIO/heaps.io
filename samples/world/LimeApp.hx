class LimeApp extends lime.app.Application {
	override public function create(c) {
		super.create(c);
		@:privateAccess World.main();
	}
}
