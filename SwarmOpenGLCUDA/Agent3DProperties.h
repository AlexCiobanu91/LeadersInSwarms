#pragma once

#include <ctime>
#include "glm\gtc\type_ptr.hpp"
#include "Definitions.h"

typedef struct LeastSquaresInfo
{
    float xAvr;
    float yAvr;
    float LAvr;
    float LaAvr;
    float LbAvr;
    float initialStep;
} LeastSquaresInfo;

typedef struct AgentProperties
{
  int agentIndex;
  int collisionType;
  int numberOfNeighbors;
  int numberOfBufferNeighbors;
  int numberOfObstacleAgents;
  int leaderID;
  int obstacleID;
  int groupID;
  int shapeGroupID;
  int leaderType;
  int separatedTimer;
  int leaderIndex;
  int color;
  int heartbeat;
  float startAngle;

  bool collision;
  bool objectCollision;
  bool isLeader;
  bool marked;
  bool avoidAgents;
  bool normalizeSpeed;
  bool computeNewCenter;
  bool customColor;

  glm::vec2 centerPosition;
  glm::vec2 previousCenterPosition;
  glm::vec2 speed;
  glm::vec2 avoidSpeed;
  glm::vec2 maintainSpeed;
  glm::vec2 neighborMeanSpeed;
  glm::vec2 obstaclePosition;
  int matrix_position;
  time_t noLeaderTimer;

  int neighborsList[1000];
  int obstacleAgents[1000];
  int neighborsBuffer[2000];

  glm::vec2 distanceFromCenter;
  glm::vec2 movementRadius;
  glm::vec4 movementMargins;
  bool slowSpeed;
  bool agentAdopting;


  int movementFrames;
  int direction;
  int leaderFrames;

  LeaderStates state;
  LeaderStates previousState;

}AgentProperties;

typedef struct Agent3DProperties {
  AgentProperties currentProperties;
  AgentProperties newProperties;

} Agent3DProperties;
