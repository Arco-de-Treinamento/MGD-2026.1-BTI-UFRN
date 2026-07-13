shader_type canvas_item;

// --- VARIÁVEIS PARA VOCÊ EDITAR NO INSPECTOR ---
uniform vec4 bg_color_top : source_color = vec4(0.0, 0.1, 0.3, 1.0);     // Azul escuro
uniform vec4 bg_color_bottom : source_color = vec4(0.0, 0.4, 0.6, 1.0);  // Ciano
uniform vec4 wave_color_1 : source_color = vec4(1.0, 1.0, 1.0, 0.8);     // Branco brilhante
uniform vec4 wave_color_2 : source_color = vec4(0.5, 0.8, 1.0, 0.6);     // Azul claro brilhante

uniform float speed = 1.0;           // Velocidade do movimento
uniform float wave_frequency = 2.5;  // Quantidade de curvas
uniform float wave_amplitude = 0.2;  // Altura da onda
uniform float glow_intensity = 0.015; // Espessura/Brilho da fita

void fragment() {
    // 1. Cria o fundo em gradiente (mistura o topo e a base usando a posição Y)
    vec4 background = mix(bg_color_top, bg_color_bottom, UV.y);
    
    // O tempo multiplicado pela velocidade
    float t = TIME * speed;
    
    // 2. Calcula a posição Y da PRIMEIRA onda (Seno)
    float wave1_y = 0.5 + sin(UV.x * wave_frequency + t) * wave_amplitude;
    // Adiciona uma distorção secundária para não ficar uma onda "perfeita" e artificial
    wave1_y += cos(UV.x * wave_frequency * 2.0 - t * 1.5) * (wave_amplitude * 0.3);
    
    // 3. Calcula a posição Y da SEGUNDA onda (Cosseno - para cruzar com a primeira)
    float wave2_y = 0.5 + cos(UV.x * (wave_frequency * 0.8) - t * 1.2) * (wave_amplitude * 1.2);
    
    // 4. Cria o efeito de "Glow" (Brilho neon). 
    // A matemática aqui faz o brilho ficar fortíssimo no centro da linha e sumir suavemente nas bordas
    float dist1 = abs(UV.y - wave1_y);
    float glow1 = glow_intensity / (dist1 + 0.005);
    
    float dist2 = abs(UV.y - wave2_y);
    float glow2 = (glow_intensity * 0.8) / (dist2 + 0.005);
    
    // 5. Soma as cores: Fundo + Onda 1 + Onda 2
    vec4 final_color = background;
    final_color += wave_color_1 * glow1;
    final_color += wave_color_2 * glow2;
    
    // Garante que as cores não passem do limite máximo de brilho
    COLOR = clamp(final_color, 0.0, 1.0);
}