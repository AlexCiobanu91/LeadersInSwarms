//-------------------------------------------------------------------------------------------------
// Descriere: header in care este definita si implementata camera
// Nota:
//		camera este capabila de operatie de rotatie si translatie pe toate axele
//		camera este capabila de rotatii FP(first person) cat si TP(third person)
//
// Autor: Lucian Petrescu
// Data: 14 oct 2013
//-------------------------------------------------------------------------------------------------
#pragma once


	struct CamVertexFormat{ 
		glm::vec3 position, color; 
		CamVertexFormat(const glm::vec3 &p, const glm::vec3 &c){ 
			position=p; color=c;
		} 
	};


	class Camera{
	public:
		glm::vec3 position;
		glm::vec3 up;
		glm::vec3 forward;
		glm::vec3 right;
		
		Camera(){
			//initializeaza camera
			position = glm::vec3(0,0,50);
			forward = glm::vec3(0,0,-1);
			up = glm::vec3(0,1,0);
			right = glm::vec3(1,0,0);
		}
		Camera(const glm::vec3 &position, const glm::vec3 &center, const glm::vec3 &up){
			//set camera
			set(position, center,up);
		}

		~Camera(){
		}

		
		void set(const glm::vec3 &position, const glm::vec3 &center, const glm::vec3 &up){
			//update camera
			this->position = position;
			forward = glm::normalize(center-position);
			right = glm::cross(forward, up);
			this->up=glm::cross(right,forward);
		}

		void translateForward(float distance)
		{
			//translatie
			position+=forward*distance;
		}

		void translateUpword(float distance)
		{
			//translatie
			position+=up*distance;
		}

		void translateRight(float distance)
		{
			//translatie
			position+=right*distance;
		}

		void rotateFPSoX(float angle)
		{
			//rotatie	
			up = up * cos(angle) + forward * sin(angle);
			forward = glm::cross(up,right);
		}

		void rotateFPSoY(float angle)
		{
			//rotatie
			forward = forward * cos(angle) + right * sin(angle);
			right = glm::cross(forward,up);
		}

		void rotateFPSoZ(float angle)
		{
			//rotatie
			right = right * cos(angle) + up * sin(angle);
			up =glm::cross( right,forward);
		}

		void rotateTPSoX(float angle, float distance)
		{
			//rotatie
			translateForward(distance);
			rotateFPSoX(angle);
			translateForward(-distance);
		}

		void rotateTPSoY(float angle, float distance)
		{
			//rotatie
			translateForward(distance);
			rotateFPSoY(angle);
			translateForward(-distance);
		}

		void rotateTPSoZ(float angle, float distance)
		{
			//rotatie
			translateForward(distance);
			rotateFPSoZ(angle);
			translateForward(-distance);
		}	
		glm::mat4 getViewMatrix(){
			return glm::lookAt(position,position + glm::normalize(forward), up);
		}

	private:
		unsigned int vao,vbo,ibo;
	};