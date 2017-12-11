#pragma once
#include <sstream>
#include <iomanip>
#include <string>
#include <iostream>
#include <algorithm>
#include <ctime>
#include <vector>
#include "GL\glew.h"
#include "GL\freeglut.h"
#include "glm\gtc\matrix_transform.hpp"
#include "glm\gtc\type_ptr.hpp"
#include "glm\glm.hpp"
#include "GLFW\glfw3.h"

const glm::vec2 MovementPercentages = glm::vec2(0.2, 0.2);
const glm::vec4 MapCoords = glm::vec4(0, 18000, 0, 10000);


const float MaxSpeed = 20;
const float ObstacleSpeed = 20;
const float ModelSize = 80;
const float ObstacleSize = ModelSize * 6;
const float AdoptionThreshold = 80;
const float InfluenceDistance = ModelSize * 10;
const float InfluenceArea = ModelSize * 2;
const float LeaderInfluence = 0.8f;
const float EnergyPercentPerFrame = 0.5;
const float Seed = 9867423;
const float NeighborDistance = ModelSize * 3;
const float AgentDistance = ModelSize * 2;
const float TargetThreshold = 0.05f;

const int InfluenceTime = 4;
const int LeaderLifeTime = 60;
const int LeaderLifeSpan = 10;
const int Leaders = 0;
const int SwarmSize = 1000;
const int NoIterations = 10;
const int NoFrames = 5000;
const int MinSwarmAgents = 20;
const int MaxThreadsPerBlock = 1024;
const int Obstacles = 0;
const int SquareIterations = 20;
const int HorizontalLineIterations = 10;
const int VerticalLineIterations = 10;
const int DiagonalIterations = 10;
const int CircleIterations = 360;
const int INF = 999;
const int PositionRadius = 99;
const int DistanceThreshold = 10;
const int SeparationThreshold = 25;
const int MovementFrames = 50;
const int InitialEnergy = 100;
const int SubLeaderLifeTime = 100;
const int SubLeaderLifeTime3 = 50;
const int CircleRadiusTarget = 1430;
const int CircleRadiusTarget3 = 930;

// leader placement
enum LeaderPlacement {
  CenterPlacement = 1,
  RandomPlacement = 0,
  BorderPlacement = 2
};

// simulation type
enum SimulationType {
  SimpleSimulation = 0,
  EnergySimulation = 1
};

// avoidance type
enum AvoidanceType {
  AvoidanceAll = 0,
  AvoidanceLeader = 1,
  AvoidanceEmerge = 2
};

// center constants
enum Centers {
  SwarmCenter = 1,
  EnvCenter = 2,
  BothCenters = 3
};

// leader types
enum LeaderType {
  MotivationLeader = 1,
  IndependentLeader = 2,
  CenterMotivationLeader = 3,
  BorderMotivationLeader = 4,
  CenterIndependentLeader = 5,
  BorderIndependentLeader = 6,
  MixedLeader = 7,
  MixedLeaderCollisionEmerge = 8,
  AvoidanceEmergeLeader = 9,
  ShapeForming = 10,
  ShapeSubLeader = 11
};

// leader states
enum LeaderStates {
  GatherFollowersState = 0,
  SlowDownState = 1,
  MoveToSwarmCenterState = 2,
  MoveToEnvCenterState = 3,
  ShapeMovementState = 4,
  ChooseShapeState = 5,
  CreateSubLeaders = 6,
  WaitForSubLeaders = 7,
  SwitchShape = 8,
  FinishMovement = 9,

  CreateSquareSubLeaders = 10
};

// movement shapes
enum MovementShapes {
  Circle = 0,
  Square = 1,
  Triangle = 2,

  HorizontalLineLR = 3,
  HorizontalLineLR_HalfL = 4,
  HorizontalLineLR_HalfR = 5,

  HorizontalLineRL = 6,
  HorizontalLineRL_HalfL = 7,
  HorizontalLineRL_HalfR = 8,

  VerticalLineUD = 9,
  VerticalLineUD_HalfU = 10,
  VerticalLineUD_HalfD = 11,

  VerticalLineDU = 12,
  VerticalLineDU_HalfU = 13,
  VerticalLineDU_HalfD = 14,

  MainDiagonalLR = 15,
  MainDiagonalLR_HalfL = 16,
  MainDiagonalLR_HalfR = 17,

  MainDiagonalRL = 18,
  MainDiagonalRL_HalfL = 19,
  MainDiagonalRL_HalfR = 20,

  AntiDiagonalLR = 21,
  AntiDiagonalLR_HalfL = 22,
  AntiDiagonalLR_HalfR = 23,

  AntiDiagonalRL = 24,
  AntiDiagonalRL_HalfL = 25,
  AntiDiagonalRL_HalfR = 26,

  UserControlled = 27
};

//user direction
enum UserDirection {
	UserUP = 0,
	UserDOWN = 1,
	UserLEFT = 2,
	UserRIGHT = 3,
	UserNoDirection =4
};

const std::string DataFolder = "Data_";
const std::string AgentsWithoutLeaders = "AgentsWithoutLeaders.txt";

/*
fisAgentsWithoutLeaders.open(fis + "AgentsWithoutLeaders.txt");
fisNumberOfAgentsPerLeader.open(fis + "NumberOfAgentsPerLeader.txt");
fisNumberOfSwarms.open(fis + "NumberOfSwarms.txt");
fisNumberOfZonesPerLeader.open(fis + "NumberOfZonesPerLeader.txt");
fisZonesWithoutLeaders.open(fis + "ZonesWithoutLeaders.txt");
fisNumberOfCollisions.open(fis + "NumberOfCollisions.txt");
fisEnergyConsumedPerMotivationLeader.open(fis + "EnergyConsumedMotivation.txt");
fisEnergyConsumedPerIndependentLeader.open(fis + "EnergyConsumedIndependent.txt");
fisAgentsInsideObstacleInfluence.open(fis + "AgentsObstaclesInfluence.txt");

fisAgentsWithoutLeaders << "Frames\tAgents without leader\tAgents with leader" << std::endl;
fisNumberOfAgentsPerLeader << "Frames\tLeader number\tAgents per leader" << std::endl;
fisNumberOfSwarms << "Frames\tNumber of swarms\tAverage agents per swarm" << std::endl;
fisNumberOfZonesPerLeader << "Frames\tLeader number\tZones per leader" << std::endl;
fisZonesWithoutLeaders << "Frames\tZones without leader\tZones with leader" << std::endl;
fisNumberOfCollisions << "Frames\tNumber of collisions" << std::endl;
fisEnergyConsumedPerMotivationLeader << "Frames\tLeader Number\tEnergy consumption" << std::endl;
fisEnergyConsumedPerIndependentLeader << "Frames\tLeader Number\tEnergy consumption" << std::endl;
fisAgentsInsideObstacleInfluence << "Frames\tObstacle number\tNumber of agents" << std::endl;

*/



