// Modelo: agnes-3-flash (Sapiens AI)
// Plataforma: Kilo Code
// Fecha: 2026-10-22
//
// M90/M47: shader de caustics procedural (solo ultra). Aproxima la red de luz
// refractada bajo el agua con capas de seno/coseno (sin textura). Se aplica a una
// superficie bajo el agua (suelo/rocas) para el efecto de causticas de agua.
// Es aditivo/suave: modula el albedo por la intensidad de la caustica.

shader_type spatial;
render_mode unshaded, cull_back, blend_add;

// Intensidad del efecto (0.0-1.0). En ultra ~0.6; en otras calidades desactivado.
uniform float caustics_strength : hint_range(0.0, 1.0) = 0.6;
// Escala espacial del patron (mas alto = causticas mas finas).
uniform float caustics_scale : hint_range(1.0, 64.0) = 12.0;
// Velocidad de la animacion (ciclos/s).
uniform float caustics_speed : hint_range(0.0, 2.0) = 0.35;
// Color de la luz refractada.
uniform vec4 color_caustica : source_color = vec4(0.75, 0.92, 1.0, 1.0);

float caustica(vec2 uv, float t) {
	vec2 p = uv * caustics_scale;
	float c1 = sin(p.x + t + cos(p.y + t * 1.1)) + cos(p.y + t * 0.9 + sin(p.x - t * 0.7));
	float c2 = sin(p.x * 0.7 - p.y + t * 1.3) + cos(p.y * 0.8 + p.x + t);
	float v = (c1 + c2) * 0.5 + 1.0;          // rango ~[0,4]
	v = 1.0 - v * 0.25;
	return smoothstep(0.55, 0.95, clamp(v, 0.0, 1.0));
}

void fragment() {
	vec2 uv = ALBEDO_UV;            // UV de la superficie
	float c = caustica(uv, TIME * caustics_speed);
	ALBEDO = color_caustica.rgb;
	ALPHA = c * caustics_strength;   // la caustica modula la luz
}
