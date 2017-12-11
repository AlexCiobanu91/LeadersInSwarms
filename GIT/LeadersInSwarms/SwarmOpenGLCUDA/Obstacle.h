#pragma once

#include "glm\gtc\type_ptr.hpp"
#include "vector"
#include "VertexFormat.h"
#include "ObstacleProperties.h"
class Obstacle
{
public:

	ObstacleProperties o;
	
	Obstacle(int index, int modelSize, glm::vec2 centerPosition, glm::vec2 speed, std::vector<VertexFormat>* vertices, std::vector<glm::uvec3>* indexes) 
	{
		o.index = index;
		o.centerPosition = centerPosition;
		o.speed = speed;
		create(vertices, indexes, index, modelSize);
	}
		
	ObstacleProperties getProperties()
	{
		return o;
	}
	void create(std::vector<VertexFormat>* vertices, std::vector<glm::uvec3>* indexes, int agentIndex, int modelSize)
	{
		vertices->push_back(VertexFormat(o.centerPosition.x - 0.5f * modelSize,
			0,
			o.centerPosition.y - 0.5f * modelSize, 1, 1, 1, 1));

		vertices->push_back(VertexFormat(o.centerPosition.x + 0.5f * modelSize,
			0,
			o.centerPosition.y - 0.5f * modelSize, 1, 1, 1, 1));

		vertices->push_back(VertexFormat(o.centerPosition.x + 0.5f * modelSize,
			0,
			o.centerPosition.y + 0.5f * modelSize, 1, 1, 1, 1));

		vertices->push_back(VertexFormat(o.centerPosition.x - 0.5f * modelSize,
			0,
			o.centerPosition.y + 0.5f * modelSize, 1, 1, 1, 1));

		int offset = agentIndex * 4;
		indexes->push_back(glm::uvec3(offset + 0, offset + 1, offset + 2));
		indexes->push_back(glm::uvec3(offset + 2, offset + 3, offset + 0));
	}
};