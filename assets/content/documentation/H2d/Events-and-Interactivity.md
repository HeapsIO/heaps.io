# Events and interaction

Making objects interactive is done creating a [`h2d.Interactive`](api/h2d/Interactive.html) instance. You provide it an interaction area and attach it to a sprite.

```haxe
var interaction = new h2d.Interactive(300, 100, mySprite);
interaction.onOver = function(event) {
	mySprite.alpha = 0.7;
}
interaction.onOut = function(event) {
	mySprite.alpha = 1;
}
interaction.onPush = function(event) {
	trace("down!");
}
interaction.onRelease = function(event) {
	trace("up!");
}
interaction.onClick = function(event) {
	trace("click!");
}
```

All events callbacks receive a [`hxd.Event`](api/hxd/Event.html) instance, which contains info about the event.