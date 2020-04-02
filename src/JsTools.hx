class JsTools {
	public static function main() {
		new JsTools();
	}

	inline static function j(q:String) {
		return js.Browser.document.querySelector(q);
	}

	public function new() {
		j(".mobileMenu").onclick = function(e) {
			j(".top-nav").classList.toggle("open");
			e.preventDefault();
		}
	}
}
