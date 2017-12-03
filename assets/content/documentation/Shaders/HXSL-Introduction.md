# Hxsl

> Haxe Shader Language

Today hardware accelerated 3D rendering is using "shaders" in order to perform many tasks :

Vertex shaders are used for transforming and projecting each geometry point into 2D space and set up "variables" that will be interpolated on a per-pixel basis. This can be used by the pixel shader.
Fragment shaders are used for blending different textures and colors into a single pixel color that will be written to screen.
Thanks to [macros](https://haxe.org/manual/macro.html), we were able to develop a high level shader language called HxSL (Haxe Shader Language) that uses Haxe syntax and can directly be embedded into Haxe programs source. HxSL translates shaders to the shader languages of the used platform.

## Shader expression

The syntax of the shader follows the syntax of Haxe language, however only a subset of the language is supported. Here's a HxSL shader expression example:

```
package h3d.shader;

class SinusDeform extends hxsl.Shader {

	static var SRC = {
		@global var time : Float;
		@param var speed : Float;
		@param var frequency : Float;
		@param var amplitude : Float;

		var calculatedUV : Vec2;

		function fragment() {
			calculatedUV.x += sin(calculatedUV.y * frequency + time * speed) * amplitude;
		}

	};

	public function new( frequency = 10., amplitude = 0.01, speed = 1. ) {
		super();
		this.frequency = frequency;
		this.amplitude = amplitude;
		this.speed = speed;
	}
}
```

### Variable Types

Among the variables used as part of an HxSL shader, we distinguish the following types of variables :

* `@param` is a shader parameter, passed for one render call for all vertexes/pixels
* `@const` is a compilation constant, it will optimize the shader at compile time to get rid of it based on the value. They do not vary for the scene being currently rendered: something like a light position would be a good example. If you are coming from another shader language, you may know of these as "Uniforms".
* `@var` is a varying, it is written in vertex shader and read in pixel shader
* `@global` means that the variables are shared among many shaders and stored in the "context globals" (so it's not per-shader)
* `@input` the input variables are the ones that come from the vertex buffer
* `@tmp` : a temporary variable, used for locals
* `@ignore` is just for prevent listing in some high level shader UI that's been worked on.
