#pragma once
#include "Includes.h"
class Agent3D
{
private:
  Agent3DProperties a3p;

public:
  Agent3D(glm::vec2 startingPosition, float modelSize, glm::vec2 startSpeed, int agentIndex,
    std::vector<VertexFormat>& vertices, std::vector<glm::uvec3>& indexes)
  {
    initProperties();

    a3p.currentProperties.agentIndex = agentIndex;  
    a3p.currentProperties.centerPosition = startingPosition;
    a3p.currentProperties.previousCenterPosition = startingPosition;
    a3p.currentProperties.speed = startSpeed;

    memcpy(&a3p.newProperties, &a3p.currentProperties, sizeof(a3p.currentProperties));

    create(vertices, indexes, agentIndex, modelSize);
    //createCircle();
  }

  void setPosition(glm::vec2 position) {
    a3p.currentProperties.centerPosition = position;
    a3p.currentProperties.previousCenterPosition = position;
  }

  void initProperties() {
    a3p.currentProperties.agentIndex = -1;
    a3p.currentProperties.collisionType = 0;
    a3p.currentProperties.numberOfNeighbors = 0;
    a3p.currentProperties.numberOfBufferNeighbors = 0;
    a3p.currentProperties.numberOfObstacleAgents = 0;
    a3p.currentProperties.leaderID = -1;
    a3p.currentProperties.obstacleID = -1;
    a3p.currentProperties.groupID = -1;
    a3p.currentProperties.shapeGroupID = -1;
    a3p.currentProperties.leaderType = -1;
    a3p.currentProperties.separatedTimer = 0;
    a3p.currentProperties.leaderIndex = -1;
    a3p.currentProperties.color = -1;
    a3p.currentProperties.heartbeat = 0;
    a3p.currentProperties.startAngle = 0;

    a3p.currentProperties.collision = false;
    a3p.currentProperties.objectCollision = false;
    a3p.currentProperties.isLeader = false;
    a3p.currentProperties.marked = false;
    a3p.currentProperties.avoidAgents = false;
    a3p.currentProperties.normalizeSpeed = true;
    a3p.currentProperties.computeNewCenter = false;
    a3p.currentProperties.customColor = false;

    a3p.currentProperties.centerPosition = glm::vec2(0, 0);
    a3p.currentProperties.speed = glm::vec2(0, 0);
    a3p.currentProperties.avoidSpeed = glm::vec2(0, 0);
    a3p.currentProperties.maintainSpeed = glm::vec2(0, 0);
    a3p.currentProperties.neighborMeanSpeed = glm::vec2(0, 0);
    a3p.currentProperties.obstaclePosition = glm::vec2(0, 0);
    a3p.currentProperties.matrix_position = -1;
    a3p.currentProperties.noLeaderTimer = 0;

    for (int i = 0; i < 200; i++) {
      a3p.currentProperties.neighborsList[i] = 0;
      a3p.currentProperties.obstacleAgents[i] = 0;
    }

    for (int i = 0; i < 2000; i++) {
      a3p.currentProperties.neighborsBuffer[i] = 0;
    }

    a3p.currentProperties.distanceFromCenter = glm::vec2(0, 0);
    a3p.currentProperties.movementRadius = glm::vec2(0, 0);
    a3p.currentProperties.movementMargins = glm::vec4(0, 0, 0, 0);

    a3p.currentProperties.slowSpeed = false;
    a3p.currentProperties.agentAdopting = true;

    a3p.currentProperties.movementFrames = 0;
    a3p.currentProperties.direction = 0;
    a3p.currentProperties.leaderFrames = 0;

    a3p.currentProperties.state = GatherFollowersState;
    a3p.currentProperties.previousState = GatherFollowersState;

  }

  Agent3DProperties getProperties()
  {
    return a3p;
  }

  void create(std::vector<VertexFormat> &vertices, std::vector<glm::uvec3> &indexes, int agentIndex, float modelSize)
  {

    vertices[agentIndex * 4] = VertexFormat(a3p.currentProperties.centerPosition.x - 2.0f * modelSize / 3.0f,
      0,
      a3p.currentProperties.centerPosition.y - modelSize / 3.0f, 1, 1, 1, 1);

    vertices[agentIndex * 4 + 1] = VertexFormat(a3p.currentProperties.centerPosition.x + modelSize / 3.0f,
      0,
      a3p.currentProperties.centerPosition.y - modelSize / 3.0f, 1, 1, 1, 1);

    vertices[agentIndex * 4 + 2] = VertexFormat(a3p.currentProperties.centerPosition.x,
      0,
      a3p.currentProperties.centerPosition.y + 2.0f * modelSize / 3.0f, 1, 1, 1, 1);

    vertices[agentIndex * 4 + 3] = VertexFormat(a3p.currentProperties.centerPosition.x,
      10.0f,
      a3p.currentProperties.centerPosition.y + 2.0f * modelSize / 3.0f, 1, 1, 1, 1);


    /*
    vertices->push_back(VertexFormat(a3p.centerPosition.x - modelSize ,
        a3p.centerPosition.y,
        a3p.centerPosition.z - modelSize, 1, 1, 1, 1));

    vertices->push_back(VertexFormat(a3p.centerPosition.x - modelSize ,
        a3p.centerPosition.y,
        a3p.centerPosition.z + modelSize, 1, 1, 1, 1));

    vertices->push_back(VertexFormat(a3p.centerPosition.x + modelSize ,
        a3p.centerPosition.y,
        a3p.centerPosition.z + modelSize, 1, 1, 1, 1));

    vertices->push_back(VertexFormat(a3p.centerPosition.x + modelSize ,
        a3p.centerPosition.y + 10.0f,
        a3p.centerPosition.z - modelSize, 1, 1, 1, 1));
    */

    int offset = agentIndex * 4;
    indexes[agentIndex * 5] = (glm::uvec3(offset + 1, offset + 2, offset + 0));
    indexes[agentIndex * 5 + 1] = (glm::uvec3(offset + 2, offset + 0, offset + 1));
    indexes[agentIndex * 5 + 2] = (glm::uvec3(offset + 0, offset + 3, offset + 2));
    indexes[agentIndex * 5 + 3] = (glm::uvec3(offset + 0, offset + 1, offset + 3));
    indexes[agentIndex * 5 + 4] = (glm::uvec3(offset + 3, offset + 1, offset + 2));

    /*
    indexes->push_back(glm::uvec3(offset + 1, offset + 2, offset + 0));
    indexes->push_back(glm::uvec3(offset + 2, offset + 3, offset + 0));
    */
  }

  ~Agent3D(void)
  {

  }
};
