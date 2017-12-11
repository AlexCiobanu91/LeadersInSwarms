#pragma once

#include "glm\gtc\type_ptr.hpp"

class ResearchDetails {
public:
	int noAgentsWithoutLeaders;
	int noZonesControlled;

	int agentsPerLeader[16];
	int zonesPerLeader[16];
	int agentsInObstacleArea[10];

	float energyConsumedM[8];
	float energyConsumedI[8];
	int energyIBorrow[8];
	int energyMBorrow[8];
	int framesMotivation[8];
	int framesIndependent[8];

	int collisions;
	int neighborsBuffer[1000];
	int swarms[1000];

	int numberOfSwarms;
	int biggestSwarm;
	int numberOfNeighbors;

	float averageAgentsPerSwarm;
};

class Frames {
public:
	int frames;
};