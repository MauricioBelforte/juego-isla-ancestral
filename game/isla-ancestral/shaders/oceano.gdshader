// Modelo: deepseek-v4-flash-vision-exp
// Plataforma: Kilo Code
// Fecha: 2026-09-03
//
// M51: Océano v2 — MUY sutil (fix "mareo" del usuario 07:24).
// Olas pequeñas y lentas (amplitud 0.04, velocidad 0.15, escala 0.6) y color
// con destellos leves (mixed 10%). La percepción: agua quieta con brillitos
// que se mueven — sin que la superficie "se meza" al caminar.

shader_type spatial;
render_mode cull_back, diffuse_lambert;

uniform float amplitud : hint_range(0.0, 0.5) = 0.04;
uniform float velocidad : hint_range(0.0, 3.0) = 0.15;
uniform float escala : hint_range(0.0, 3.0) = 0.6;
uniform vec4 color_agua : source_color = vec4(0.10, 0.45, 0.75, 1.0);
uniform vec4 color_cresta : source_color = vec4(0.16, 0.55, 0.82, 1.0);

float ola(vec3 p, float t) {
	return sin(p.x * escala + t * velocidad) * cos(p.z * escala * 0.8 - t * velocidad * 0.6);
}

void vertex() {
	// desplazamiento casi nulo: solo una leve ondulación para vida
	VERTEX.y += amplitud * ola(VERTEX, TIME);
}

void fragment() {
	float o = 0.5 + 0.5 * ola(VERTEX, TIME);
	// variación de color leve (10%) — sin "mareo" por cambio fuerte
	ALBEDO = mix(color_agua.rgb, color_cresta.rgb, o * 0.10);
	SPECULAR = 0.35 + 0.25 * o;
	ROUGHNESS = 0.5 - 0.08 * o;
	METALLIC = 0.05;
}
