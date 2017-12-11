#pragma once

class VertexFormat
{
public:
	glm::vec3 pozitie;
	glm::vec4 culoare;
	VertexFormat() {
		pozitie = glm::vec3(0, 0, 0);
		culoare = glm::vec4(1, 1, 1, 1);

	}
	VertexFormat(float px, float py, float pz, float cx, float cy, float cz, float alpha) {
		pozitie = glm::vec3(px, py, pz);
		culoare = glm::vec4(cx, cy, cz, alpha);
	}
};