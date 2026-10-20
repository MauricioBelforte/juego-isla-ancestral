// Modelo: agnes-3-flash (Sapiens AI)
// Plataforma: Kilo Code
// Fecha: 2026-10-22
//
// M90/M50: shader de viento para vegetacion. Desplaza el VERTEX (la cima se
// mueve mas que la base, por UV.y) segun vector de viento + senal de tiempo.
// Solo declara vertex(): el fragment conserva albedo/normal del material.

shader_type spatial;
render_mode cull_back;

uniform float amplitud : hint_range(0.0, 2.0) = 0.35;
uniform float frecuencia : hint_range(0.1, 5.0) = 1.2;
uniform vec3 direccion_viento : source_color = vec3(0.4, 0.1, 0.0);
uniform float capa_mask : hint_range(0.0, 1.0) = 1.0;
uniform float fase : hint_range(0.0, 6.28) = 0.0;

void vertex() {
    float m = clamp(UV.y, 0.0, 1.0);
    float s = sin(TIME * frecuencia + fase + POSITION.x * 0.6 + POSITION.z * 0.6) * amplitud * m * capa_mask;
    VERTEX += direccion_viento * s;
}
