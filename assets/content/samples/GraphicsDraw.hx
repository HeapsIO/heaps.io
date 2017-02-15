import h2d.filter.Glow;
class GraphicsDraw extends hxd.App {

	var bclone : h2d.Bitmap;
	var texture : h3d.mat.Texture;
	var pg : h2d.Graphics;
	private var g2:h2d.Graphics;
	private var tile:h2d.Tile;
	private var _time:Float = 0.0;

	override function init() {
		var g1 = new h2d.Graphics(s2d);
		g1.beginFill(0xFF8000);
		g1.drawRect(10, 10, 100, 100);
		g1.endFill();
		
		var g1 = new h2d.Graphics(s2d);
		g1.lineStyle(5, 0xFF8000);
		g1.drawRect(210, 10, 100, 100);
		
		g1.lineStyle(5, 0xFF8000);
		g1.beginFill(0x4E4E4E, 0.5);
		g1.drawCircle(450, 60, 50);
		g1.endFill();

		// check pie + draw texture

		g2 = new h2d.Graphics(s2d);
		var bmp = new hxd.BitmapData(64, 64);
		for( x in 0...64 )
			for( y in 0...64 )
				bmp.setPixel(x, y, 0xFF000000 | (x * 4) | ((y * 4) << 8));
		tile = h2d.Tile.fromBitmap(bmp);
		bmp.dispose();

		g2.beginTileFill(-50, -50, tile);
		g2.drawPie(0, 0, 50, Math.PI / 3, Math.PI * 5 / 4);
		g2.endFill();

		g2.beginTileFill(100, -64, 2, 2, tile);
		g2.drawRect(150, -50, 100, 100);
		g2.endFill();

		g2.x = 60;
		g2.y = 200;
		g2.filters = [new Glow(0x9BD1EE, 1, 2, 2, 2, true)];

		// check the size and alignment of scaled bitmaps

		var bmp = new hxd.BitmapData(256, 256);
		bmp.clear(0xFFFF00FF);
		bmp.fill(19, 21, 13, 15, 0xFF202020);
		bmp.fill(19, 20, 13, 1, 0xFFFF0000);
		bmp.fill(18, 21, 1, 15, 0xFF00FF00);
		bmp.fill(19+13, 21, 1, 15, 0xFF0000FF);
		bmp.fill(19, 21 + 15, 13, 1, 0xFF00FFFF);
		var tile = h2d.Tile.fromBitmap(bmp);

		bmp.dispose();

		var b = new h2d.Bitmap(tile.sub(19, 21, 13, 15), s2d);
		b.x = 400;
		b.y = 300;
		b.scale(16);

		var b = new h2d.Bitmap(tile.sub(18, 20, 15, 17), s2d);
		b.x = 430;
		b.y = 300;
		b.scale(8);

		// check drawTo texture

		texture = new h3d.mat.Texture(128, 128,[Target]);
		var b = new h2d.Bitmap(h2d.Tile.fromTexture(texture), s2d);
		b.blendMode = None; // prevent residual alpha bugs
		b.y = 356;

		// test capture bitmap

		bclone = new h2d.Bitmap(h2d.Tile.fromTexture(new h3d.mat.Texture(128, 128)), s2d);
		bclone.blendMode = None; // prevent residual alpha bugs
		bclone.x = 128 + 20;
		bclone.y = 356;

		// set up graphics instance for use in redraw()

		pg = new h2d.Graphics();
		pg.filters = [new h2d.filter.Blur(2,2,10)];
		pg.beginFill(0xFF8040, 0.5);
	}

	function redraw(t:h3d.mat.Texture) {
		pg.clear();
		for( i in 0...100 ) {
			var r = (0.1 + Math.random()) * 10;
			var s = Math.random() * Math.PI * 2;
			var a = Math.random() * Math.PI * 2;
			pg.drawPie(Math.random() * 256, Math.random() * 256, r, s, a);
		}
		pg.drawTo(t);

		var pix = t.capturePixels(true);
		bclone.tile.getTexture().uploadPixels(pix);
		pix.dispose();
		
		
		//
		
	}

	override function update(dt:Float) {
		redraw(texture);
		
		_time += dt;
		
		g2.clear();
		g2.lineStyle();

		g2.beginTileFill(-50, -50, tile);
		g2.drawPie(0, 0, 50, (_time / 50) % (Math.PI*2), (Math.PI + (_time / 75)) % (Math.PI*2));
		g2.endFill();

		g2.beginTileFill(100, -64, 2, 2, tile);
		g2.drawRect(150 + Math.sin(_time / 90) * 10, -50 + Math.cos(_time / 120) * 10, 100 + Math.sin(_time / 60) * 10, 100 + Math.cos(_time / 90) * 10);
		g2.endFill();
		
		g2.beginTileFill( -50, -50, tile);
		g2.moveTo(350 + Math.sin(_time / 30) * 10, -50 + Math.cos(_time / 40) * 10);
		g2.lineTo(350 + Math.cos(_time / 40) * 10, 50 + Math.cos(_time / 50) * 10);
		g2.lineTo(450 + Math.cos(_time / 50) * 10, 50 + Math.sin(_time / 60) * 10);
		g2.lineTo(450 + Math.sin(_time / 60) * 10 , -50 + Math.sin(_time / 70) * 10);
	}

	static function main() {
		new GraphicsDraw();
	}

}