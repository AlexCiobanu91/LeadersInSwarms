#pragma once
#pragma once

#include <ctime>
#include "glm\gtc\type_ptr.hpp"

class LeaderProperties{
public:
  glm::vec2 swarmCenter;
  glm::vec2 swarmSpeed;
  glm::vec2 leaderPosition;
  glm::vec2 leaderSpeed;
  glm::vec2 leaderSubSpeed;
  glm::vec2 movementRadius;
  glm::vec2 farthestAgentPosition;
  glm::vec2 shapeCenter;
  glm::vec2 swarmLimitsX;
  glm::vec2 swarmLimitsY;

  int heartbeat;
  int leaderDirection;
  int leaderMovementFrames;
  int followers;
  int energyMBorrow;
  int energyIBorrow;  
  int framesMotivation;
  int framesIndependent;
  int leaderAgentIndex;
  int leaderFrames;
  int shapeAgents;
  int subLeaders;
  int farthestAgent;
  int farAgents;
  int allObstacleAgents;
  int shapePosition;

  LeaderStates state;
  LeaderStates previousState;

  float energyConsumedM;
  float energyConsumedI;
  float energyPerLeader;
  float energyDebt;

  bool stillAdopting;
  bool initialShape;
  bool shapeForming;
  bool hasSubLeaders;

  float circleCenterX;
  float circleCenterY;
  float circleRadius;

  MovementShapes currentShape;
  MovementShapes targetShape;

  int numberOfShapeGroups;
  int shapeGroups[100];
};

class SimulationDetails {
public:
  float adoptionThreshold;
  float influenceTime;
  float leaderLifeSpan;
  float leaderLifeTime;
  float leaderInfluence;
  float maxSpeed;
  float obstacleSpeed;
  float influenceDistance;
  float modelSize;
  float obstacleSize;
  float energyQuantity;
  float neighborDistance;
  float agentDistance;
  float seed;
  float energyPercentPerFrame;
  float influenceArea;
  float targetThreshold;
  float circleRadiusTarget;

  int swarmSize;
  int distanceThreshold;
  int numberOfObstacles;
  int avoidanceType;
  int noLeaders;
  int currentLeaders;
  int subLeaderLifeTime;

  int separationThreshold;
  int movementFrames;
  int position_radius;
  int noFrames;
  int collisions;

  bool shapeForming;
  bool userControlled;
  bool imposedShape;
  bool dynamicObstacles;
  bool fullscreen;

  time_t influenceStartTimer;
  time_t leaderLifeTimer;
 
  LeaderType leaderType;
  SimulationType simulationType;
  MovementShapes moveShape;
  UserDirection userDirection;

  glm::vec2 movementPercentages;
  glm::vec4 mapCoords;

  int agentsInObstacleArea[10];
  glm::vec2 shapePositions[8];
  bool shapePositionsChosen[8];

  int position_matrix[10100];
  int target_matrix[10100];
  LeaderProperties lp[8];
};