#include "Includes.cuh"
#include "CommonFunctions.cuh"
#include "Constants.cuh"

#pragma once

void WriteResearch(ResearchDetails* rd, SimulationDetails *sd);

__device__ void GetAgentsWithoutLeaders(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ResearchDetails* d_rd)
{
	int agentsWithoutLeader = 0;
	for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
		if (cap->leaderID == -1) {
			agentsWithoutLeader++;
		}
	}
	d_rd->noAgentsWithoutLeaders = agentsWithoutLeader;
}

__device__ void GetNumberOfZonesControlled(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ResearchDetails *d_rd)
{
  /*
	int stepX = (abs(d_sd->minX) + abs(d_sd->maxX)) / 10;
	int stepZ = (abs(d_sd->minZ) + abs(d_sd->maxZ)) / 10;
	d_rd->noZonesControlled = 0;

	for (int i = d_sd->minX; i < d_sd->maxX; i += stepX) {
		for (int j = d_sd->minZ; j < d_sd->maxZ; j += stepZ) {
			for (int k = 0; k < d_sd->swarmSize; k++) {
        AgentProperties* cap = &d_a3pv[k].currentProperties;
				glm::vec2 agentPosition = cap->centerPosition;
				if (agentPosition.x >= i && agentPosition.x <= i + stepX &&
					agentPosition.z >= j && agentPosition.z <= j + stepZ) {
					d_rd->noZonesControlled++;
					break;
				}
			}
		}
	}
  */
}

__device__ void GetNumberOfSwarms(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ResearchDetails *d_rd)
{
	for (int i = 0; i < d_sd->swarmSize; i++) {
		d_a3pv[i].newProperties.marked = false;
		d_a3pv[i].newProperties.groupID = -1;
		d_rd->swarms[i] = 0;
	}

	d_rd->numberOfNeighbors = 0;
	d_rd->averageAgentsPerSwarm = 0;
	d_rd->biggestSwarm = 0;
	int groupID = 0;
	int totalMembers = 0;
	for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* nap = &d_a3pv[i].newProperties;
    AgentProperties* cap = &d_a3pv[i].currentProperties;
		if (!nap->marked) {
			int members = 0;
			nap->marked = true;
			nap->groupID = groupID;
			members++;


			d_rd->numberOfNeighbors = 0;
			int currentNeighbor = 0;

			for (int j = 0; j < cap->numberOfNeighbors; j++) {
				d_rd->neighborsBuffer[d_rd->numberOfNeighbors] = cap->neighborsList[j];
				d_rd->numberOfNeighbors++;
			}

			while (currentNeighbor < d_rd->numberOfNeighbors) {
				int currentNeighborIndex = d_rd->neighborsBuffer[currentNeighbor];
        AgentProperties* n_cap = &d_a3pv[currentNeighborIndex].currentProperties;
        AgentProperties* n_nap = &d_a3pv[currentNeighborIndex].newProperties;
				if (!n_cap->marked) {
          n_nap->marked = true;
          n_nap->groupID = groupID;
					members++;
				}

				for (int k = 0; k < n_cap->numberOfNeighbors; k++) {
					int newNeighborIndex = n_cap->neighborsList[k];
          AgentProperties* nn_cap = &d_a3pv[newNeighborIndex].currentProperties;
					if (!nn_cap->marked) { // !isMember(d_a3pv[i].neighborsBuffer, d_a3pv[i].numberOfBufferNeighbors, d_a3pv[currentNeighborIndex].neighborsList[k])) {
						d_rd->neighborsBuffer[d_rd->numberOfNeighbors] = newNeighborIndex;
						d_rd->numberOfNeighbors++;
					}
				}

				currentNeighbor++;
			}
			if (members >= MinSwarmAgents) {
				groupID++;
				totalMembers += members;
			}
		}
	}
	d_rd->numberOfSwarms = groupID + 1;
	d_rd->averageAgentsPerSwarm = totalMembers / (groupID + 1);
}

__device__ void GetNumberOfAgentsPerLeader(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ResearchDetails *d_rd) {
  for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
    if (cap->isLeader) {
      d_rd->agentsPerLeader[i] = d_sd->lp[cap->leaderIndex].followers;
    }
  }
}

__device__ void GetNumberOfZonesPerLeader(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ResearchDetails *d_rd, unsigned int tid)
{
  /*
	int stepX = (abs(d_sd->minX) + abs(d_sd->maxX)) / 10;
	int stepZ = (abs(d_sd->minZ) + abs(d_sd->maxZ)) / 10;
	d_rd->noZonesControlled = 0;

	int globalMap[10][10];
	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 10; j++) {
			globalMap[i][j] = 0;
		}
	}
	for (int i = 0; i < d_sd->noLeaders; i++) {
		d_rd->zonesPerLeader[i] = 0;
	}

	int x = 0;
	int z = 0;

	for (int i = d_sd->minX; i < d_sd->maxX; i += stepX) {
		for (int j = d_sd->minZ; j < d_sd->maxZ; j += stepZ) {
			//int leaderZones = 0;

			bool leaderMap[10][10];

			for (int k = 0; k < 10; k++) {
				for (int l = 0; l < 10; l++) {
					globalMap[i][j] = 0;
				}
			}

			for (int l = 0; l < d_sd->swarmSize; l++) {
				if (d_a3pv[l].leaderID != d_a3pv[tid].agentIndex) {
					continue;
				}

				glm::vec2 agentPosition = d_a3pv[l].centerPosition;
				if (agentPosition.x >= i && agentPosition.x <= i + stepX &&
					agentPosition.z >= j && agentPosition.z <= j + stepZ) {
					globalMap[x][z] ++;
					if (!leaderMap[x][z]) {
						d_rd->zonesPerLeader[d_a3pv[tid].agentIndex]++;
						leaderMap[x][z] = true;
					}
					break;
				}
			}
			z++;
		}
		x++;
	}
  */
}

__device__ void GetEnergyCoeficientPerLeader(Agent3DProperties* d_a3pv, SimulationDetails* d_sd, ResearchDetails* d_rd)
{
	for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
		if (cap->isLeader) {
			d_rd->energyConsumedI[cap->leaderIndex] = d_sd->lp[cap->leaderIndex].energyConsumedI;
			d_rd->energyConsumedM[cap->leaderIndex] = d_sd->lp[cap->leaderIndex].energyConsumedM;
			d_rd->framesIndependent[cap->leaderIndex] = d_sd->lp[cap->leaderIndex].framesIndependent;
      d_rd->framesMotivation[cap->leaderIndex] = d_sd->lp[cap->leaderIndex].framesMotivation;
		}
	}

}

__device__ void GetNumberOfAgentsInsideObstaclesArea(SimulationDetails* d_sd, ResearchDetails* d_rd)
{
	for (int i = 0; i < d_sd->numberOfObstacles; i++) {
		d_rd->agentsInObstacleArea[i] = d_sd->agentsInObstacleArea[i];
	}
}

__global__ void researchKernel(Agent3DProperties* d_a3pv, SimulationDetails* d_sd, ResearchDetails* d_rd, Frames * d_frames)
{
	const unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;

	if (d_frames->frames % 100 == 0) {
		d_rd->collisions = d_sd->collisions;
		switch (tid) {
		case 0:
			GetNumberOfSwarms(d_a3pv, d_sd, d_rd);
			break;
		case 1:
			GetNumberOfZonesControlled(d_a3pv, d_sd, d_rd);
			break;
		case 2:
			GetAgentsWithoutLeaders(d_a3pv, d_sd, d_rd);
			break;
		case 3:
			GetNumberOfAgentsPerLeader(d_a3pv, d_sd, d_rd);
			break;
		case 4:
			GetNumberOfAgentsInsideObstaclesArea(d_sd, d_rd);
			break;
		case 5:
			GetEnergyCoeficientPerLeader(d_a3pv, d_sd, d_rd);
			break;
		}

		//if (tid > 3 && tid <= 3 + d_sd->noLeaders) {
		//	GetNumberOfZonesPerLeader(d_a3pv, d_sd, d_rd, tid - 4);
		//}
	}


	if (tid == 0) {
		d_frames->frames++;
		d_sd->noFrames = d_frames->frames;
	}

}

void closeFiles() {
	fisAgentsWithoutLeaders.close();
	fisNumberOfAgentsPerLeader.close();
	fisNumberOfSwarms.close();
	fisNumberOfZonesPerLeader.close();
	fisZonesWithoutLeaders.close();
	fisNumberOfCollisions.close();
}

void InitFiles(std::string fis) {
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
}

void launchResearchKernel(SimulationDetails* sd)
{
	// setup execution parameters
	dim3 gridExecutors(6 + (int)sd->noLeaders);
	dim3 block(1);

	// researchKernel << < gridExecutors, block >> > ((Agent3DProperties *)dd_d3pv, (SimulationDetails *)dd_sd, (ResearchDetails *)dd_rd, (Frames *)dd_frames);
	// cudaDeviceSynchronize();

	const int f_size = sizeof(Frames);

	cudaMemcpy(frames, dd_frames, f_size, cudaMemcpyDeviceToHost);

	//std::cout << "NoFrames: " << frames->frames << std::endl;
	sd->noFrames = frames->frames;
	// const int sd_size = sizeof(SimulationDetails);

	if (frames->frames % 100 == 0) {
		const int rd_size = sizeof(ResearchDetails);
		cudaMemcpy(rd, dd_rd, rd_size, cudaMemcpyDeviceToHost);

		WriteResearch(rd, sd);
	}
}

void WriteResearch(ResearchDetails* rd, SimulationDetails *sd)
{
	fisAgentsWithoutLeaders << sd->noFrames << "\t" << rd->noAgentsWithoutLeaders << "\t" << sd->swarmSize - rd->noAgentsWithoutLeaders << std::endl;

	for (int i = 0; i < sd->noLeaders; i++) {
		fisNumberOfAgentsPerLeader << sd->noFrames << "\t" << i << "\t" << rd->agentsPerLeader[i] << std::endl;
		fisNumberOfZonesPerLeader << sd->noFrames << "\t" << i << "\t" << rd->zonesPerLeader[i] << std::endl;
		fisEnergyConsumedPerMotivationLeader << sd->noFrames << "\t" << i << "\t" << rd->energyConsumedM[i] / static_cast<float>(rd->framesMotivation[i]) << std::endl;
		fisEnergyConsumedPerIndependentLeader << sd->noFrames << "\t" << i << "\t" << rd->energyConsumedI[i] / static_cast<float>(rd->framesIndependent[i]) << std::endl;
	}

	for (int i = 0; i < sd->numberOfObstacles; i++) {
		fisAgentsInsideObstacleInfluence << sd->noFrames << "\t" << i << "\t" << rd->agentsInObstacleArea[i] << std::endl;
	}


	fisNumberOfSwarms << sd->noFrames << "\t" << rd->numberOfSwarms << "\t" << rd->averageAgentsPerSwarm << std::endl;

	fisZonesWithoutLeaders << sd->noFrames << "\t" << 100 - rd->noZonesControlled << "\t" << rd->noZonesControlled << std::endl;

	fisNumberOfCollisions << sd->noFrames << "\t" << rd->collisions << std::endl;




}

