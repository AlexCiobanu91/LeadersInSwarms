#pragma once
#include "Includes.cuh"

Frames* dd_frames;
Frames* frames;
Agent3DProperties* dd_d3pv;
ObstacleProperties* dd_opv;
SimulationDetails* dd_sd;
ResearchDetails* dd_rd;
ResearchDetails* rd;
cudaGraphicsResource_t agentsResource;
cudaGraphicsResource_t obstacleResource;
cudaGraphicsResource_t positionMatrixResource;

std::ofstream fisAgentsWithoutLeaders;
std::ofstream fisZonesWithoutLeaders;
std::ofstream fisNumberOfAgentsPerLeader;
std::ofstream fisNumberOfZonesPerLeader;
std::ofstream fisNumberOfSwarms;
std::ofstream fisNumberOfCollisions;
std::ofstream fisEnergyConsumedPerMotivationLeader;
std::ofstream fisEnergyConsumedPerIndependentLeader;
std::ofstream fisAgentsInsideObstacleInfluence;