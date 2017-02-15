

class World extends hxd.App {

	var world : h3d.scene.World;
	var shadow :h3d.pass.ShadowMap;

	override function init() {

		world = new h3d.scene.World(64, 256, s3d);
		var t = world.loadModel(hxd.Res.tree);
		var r = world.loadModel(hxd.Res.rock);

		for ( i in 0...3000 )
		{
			var isRock =  Std.random(2) == 0;
			world.add(!isRock ? t : r, Math.random() * 256, Math.random() * 256, 0, isRock ? 1 + hxd.Math.srand(0.6) :  1.2 + hxd.Math.srand(0.4), hxd.Math.srand(Math.PI));
		}
		world.done();

		//
		new h3d.scene.DirLight(new h3d.Vector( 0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		s3d.camera.target.set(72, 72, 0);
		s3d.camera.pos.set(120, 120, 40);

		shadow = Std.instance(s3d.renderer.getPass("shadow"), h3d.pass.ShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.passes = 1;
		shadow.bias *= 0.5;
		shadow.color.set(0.75, 0.75, 0.75);

		#if castle
		new hxd.inspect.Inspector(s3d);
		#end

		var parts = new h3d.parts.GpuParticles(world);
		parts.volumeBounds = h3d.col.Bounds.fromValues( -20, -20, 15, 40, 40, 40);
		
		s3d.camera.zNear = 1;
		s3d.camera.zFar = 100;
		new h3d.scene.CameraController(s3d).loadFromCamera();
	}


	static function main() {
		hxd.Res.initEmbed();
		new World();
	}

}