// Modelo: glm-5.3-flash
// Plataforma: Kilo Code
// Fecha: 2026-09-06
//
// M51 iter. 5: shore-fade por profundidad de pantalla (feedback usuario:
// "que las olas lleguen hasta la arena"). El plano de agua se desvanece y
// genera espuma EXACTAMENTE en la línea de costa real (comparando la
// profundidad de la escena bajo cada píxel), sin radios hardcodeados.
// - Mar abierto: olas + fresnel + espuma de crestas (gustadas por el usuario).
// - Orilla: fade suave + espuma de marea que oscila con las olas (vaivén).

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 color_agua : source_color = vec4(0.16, 0.5, 0.68, 0.72);
uniform vec4 color_profunda : source_color = vec4(0.08, 0.3, 0.5, 0.85);
uniform vec4 color_espuma : source_color = vec4(0.92, 0.97, 1.0, 0.85);
uniform sampler2D depth_texture : hint_depth_texture, filter_linear;
uniform float amplitud = 0.16;
uniform float velocidad = 1.3;
uniform float frecuencia = 0.45;
uniform float fresnel_potencia = 3.0;
uniform float borde_espuma = 0.55;
uniform float y_mar = 4.05;
// Rango de "profundidad de agua" (metros sobre el fondo) para el fade:
// < profundidad_min → alpha 0 (sobre la arena), > profundidad_max → alpha full.
uniform float profundidad_min = 0.15;
uniform float profundidad_max = 2.2;
// BUG-105 (fix 2026-10-08): con la isla ×10 el mar lejano domina el viewport y
// la espuma de crestas (color_espuma frio) promedia ~0.5 sobre toda la superficie
// lejana → manto lechoso blanco (medido RGB 187/213/230, R-B=-44). La espuma de
// crestas se desvanece con la distancia de camara; el look cercano (olas + espuma
// de crestas y de orilla, gustados en M51) queda IDENTICO.
uniform float espuma_distancia = 300.0;

varying float altura_ola;

void vertex() {
	vec3 mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Ondas de mar abierto (gustadas por el usuario — sin cambios)
	float o1 = sin(mundo.x * frecuencia + TIME * velocidad);
	float o2 = cos(mundo.z * frecuencia * 0.8 + TIME * velocidad * 0.7);
	float o3 = sin((mundo.x + mundo.z) * frecuencia * 0.5 - TIME * velocidad * 0.5);
	altura_ola = (o1 + o2 * 0.6 + o3 * 0.4) / 2.0;
	VERTEX.y += altura_ola * amplitud;
	// Normal aproximada por derivadas de la onda principal
	float dx = cos(mundo.x * frecuencia + TIME * velocidad) * frecuencia * amplitud;
	float dz = -sin(mundo.z * frecuencia * 0.8 + TIME * velocidad * 0.7) * frecuencia * 0.8 * amplitud * 0.6;
	NORMAL = normalize(vec3(-dx, 1.0, -dz));
}

void fragment() {
	// ── Profundidad de agua bajo este píxel (diferencia de profundidades) ──
	float depth_raw = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 fondo_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	fondo_view.xyz /= fondo_view.w;
	// VERTEX (fragment) y fondo_view.z son view-space (negativos hacia adelante)
	float profundidad_agua = VERTEX.z - fondo_view.z; // >0 si el fondo está detrás
	float costa = 1.0 - smoothstep(profundidad_min, profundidad_max, profundidad_agua);

	// ── Color ──
	vec3 albedo = mix(color_profunda.rgb, color_agua.rgb, clamp(altura_ola * 0.5 + 0.5, 0.0, 1.0));
	// Marea somera: cerca de la orilla apenas se aclara (agua azul, no lechosa)
	albedo = mix(albedo, vec3(0.28, 0.68, 0.78), costa * 0.28);
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), fresnel_potencia);
	ALBEDO = albedo;
	// Fade en la orilla: sobre la arena seca el plano desaparece (alpha → 0)
	ALPHA = clamp((color_agua.a + fresnel * 0.25) * (1.0 - costa) + costa * 0.45, 0.0, 0.95);
	// Espuma de crestas en mar abierto (gustadas por el usuario)
	float espuma_crestas = smoothstep(borde_espuma, 1.0, altura_ola * 0.5 + 0.5) * (1.0 - costa * 0.6);
	// BUG-105: atenuacion por distancia de camara (VERTEX.z view-space, negativo
	// hacia adelante). Mas alla de ~300 m la espuma de crestas desaparece y el
	// agua vuelve a su albedo turquesa; cerca no cambia nada.
	float dist_cam = -VERTEX.z;
	espuma_crestas *= 1.0 - smoothstep(espuma_distancia * 0.4, espuma_distancia, dist_cam);
	// Espuma de orilla: banda ESTRECHA pegada a la arena (vaivén natural)
	float vaiven = 0.6 + 0.4 * sin(TIME * 1.6 + altura_ola * 2.0);
	float espuma_orilla = (1.0 - smoothstep(0.0, profundidad_max * 0.22, profundidad_agua)) * vaiven;
	float espuma = clamp(espuma_crestas + espuma_orilla, 0.0, 1.0);
	ALBEDO = mix(ALBEDO, color_espuma.rgb, espuma * 0.85);
	ALPHA = mix(ALPHA, color_espuma.a, espuma * 0.7);
	// BUG-105 (fix 2026-10-08): SPECULAR=0. Un specular 0.5 con roughness 0.15
	// a angulos rasantes producia la banda blanca lechosa sobre todo el mar
	// (causa dominante; verificado con capturas: cap_105_debug_prof_costa_espuma
	// muestra prof/costa/espuma sanos en la banda, cap_105_test_sin_specular
	// elimina la leche). El brillo del agua queda del fresnel en ALPHA.
	// Sparks de sol: futura iteracion M51 si el usuario los pide.
	SPECULAR = 0.0;
	ROUGHNESS = 0.15;
	EMISSION = color_espuma.rgb * espuma * 0.12;
}
