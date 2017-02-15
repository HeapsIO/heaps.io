//PARAM=-D resourcesPath=../../skin_res

class Interactive extends hxd.App {

	var rnd : hxd.Rand;
	var light : h3d.scene.DirLight;
	var obj : h3d.scene.Object;
	var b : h2d.Interactive;

	function initInteract( i : h3d.scene.Interactive, m : h3d.scene.Mesh ) {
		var beacon = null;
		var color = m.material.color.clone();
		i.onOver = function(e : hxd.Event) {
			m.material.color.set(0, 1, 0);
			var s = new h3d.prim.Sphere(1, 32, 32);
			s.addNormals();
			beacon = new h3d.scene.Mesh(s, m);
			beacon.material.mainPass.enableLights = true;
			beacon.material.color.set(1, 0, 0);
			beacon.scale(0.05 / m.parent.scaleX);
			beacon.x = e.relX;
			beacon.y = e.relY;
			beacon.z = e.relZ;
		};
		i.onMove = function(e:hxd.Event) {
			if( beacon == null ) return;
			beacon.x = e.relX;
			beacon.y = e.relY;
			beacon.z = e.relZ;
		};
		i.onOut = function(e : hxd.Event) {
			m.material.color.load(color);
			beacon.remove();
			beacon = null;
		};
	}

	override function init() {
		light = new h3d.scene.DirLight(new h3d.Vector( 0.3, -0.4, -0.9), s3d);
		light.enableSpecular = true;
		light.color.set(0.28, 0.28, 0.28);
		s3d.lightSystem.ambientLight.set(0.74, 0.74, 0.74);

		rnd = new hxd.Rand(5);
		for(i in 0...8) {
			var c = if( rnd.random(2) == 0 ) new h3d.prim.Cube() else new h3d.prim.Sphere(1,64,32);
			//c.unindex();
			c.addNormals();
			c.addUVs();
			var m = new h3d.scene.Mesh(c, s3d);
			m.x = rnd.srand() * 0.9;
			m.y = rnd.srand() * 0.9;
			m.scale(0.25 + rnd.rand() * 0.3);
			m.material.mainPass.enableLights = true;
			m.material.shadows = true;
			var c = 0.3 + rnd.rand() * 0.3;
			var color = new h3d.Vector(c, c * 0.6, c * 0.6);
			m.material.color.load(color);

			var interact = new h3d.scene.Interactive(m.primitive.getCollider(), m);
			initInteract(interact, m);
		}

		var cache = new h3d.prim.ModelCache();
		obj = cache.loadModel(hxd.Res.Model);
		obj.scale(1 / 20);
		obj.rotate(0,0,Math.PI / 2);
		obj.y = 0.2;
		obj.z = -0.2;

		// disable skinning (not supported for picking)
		var pass = obj.getChildAt(1).toMesh().material.mainPass;
		pass.removeShader(pass.getShader(h3d.shader.Skin));
		s3d.addChild(obj);

		for( o in obj ) {
			var m = o.toMesh();
			var i = new h3d.scene.Interactive(m.primitive.getCollider(), o);
			initInteract(i, m);
		}

		b = new h2d.Interactive(150, 100, s2d);
		b.backgroundColor = 0x80204060;
		b.rotation = Math.PI / 3;
		//b.scaleX = 1.5; // TODO

		var pix = null;
		b.onOver = function(e) {
			var t = h2d.Tile.fromColor(0xFF0000, 3, 3);
			t.dx = -1;
			t.dy = -1;
			pix = new h2d.Bitmap(t, b);
			pix.x = e.relX;
			pix.y = e.relY;
		};
		b.onMove = function(e) {
			if( pix == null ) return;
			pix.x = e.relX;
			pix.y = e.relY;
		}
		b.onOut = function(e) {
			pix.remove();
			pix = null;
		};
		
		onResize();
	}
	
	override function onResize() {
		b.x = (s2d.width >> 1) - 200;
		b.y = 150;
	}

	override function update(dt:Float) {
		obj.rotate(0, 0, 0.01 * dt);
	}


	static function main() {
		hxd.Res.initEmbed();
		new Interactive();
	}
}