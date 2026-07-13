shader_type canvas_item;

// Cores base (Cinza claro para Cinza Escuro)
uniform vec4 color_top : source_color = vec4(0.3, 0.3, 0.3, 1.0); 
uniform vec4 color_bottom : source_color = vec4(0.1, 0.1, 0.1, 1.0); 

// Quantidade de "degraus" (faixas) no degradê. Quanto menor, mais pixelado.
uniform float steps : hint_range(2.0, 32.0, 1.0) = 8.0; 

void fragment() {
    // Pega a coordenada Y (de 0.0 no topo até 1.0 na base da tela)
    float y = UV.y;
    
    // Arredonda a posição Y com base na quantidade de 'steps' para criar o efeito pixelado
    float banded_y = floor(y * steps) / (steps - 1.0);
    
    // Mistura as duas cores usando a posição arredondada
    COLOR = mix(color_top, color_bottom, banded_y);
}
