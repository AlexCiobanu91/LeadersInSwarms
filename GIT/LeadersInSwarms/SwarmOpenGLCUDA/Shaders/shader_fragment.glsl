out vec4 out_color;

in vec4 vertex_to_fragment_color;

void main(){
	gl_FragColor = vertex_to_fragment_color;
}