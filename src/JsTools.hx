import js.jquery.JQuery;

class JsTools {
	public static function main() {
		j("window").ready( function() {
			new JsTools();
		});
	}

	static function j(q:String) : JQuery {
		return new js.jquery.JQuery(q);
	}

	public function new() {
		j(".mobileMenu").click( function(e) {
			j(".top-nav").toggleClass("open");
			e.preventDefault();
		});
	}
}
