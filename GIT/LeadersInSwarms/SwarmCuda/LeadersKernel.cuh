#include "Includes.cuh"

#pragma once

__device__ void createRandomLeaders(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, SimulationDetails* d_sd, unsigned int tid)
{
	int leaderIndex = -1;
	while (d_sd->currentLeaders < d_sd->noLeaders) {
		leaderIndex++;
    AgentProperties *nap = &d_a3pv[leaderIndex].newProperties;
    AgentProperties *cap = &d_a3pv[leaderIndex].currentProperties;
    nap->isLeader = true;
    nap->leaderType = d_sd->leaderType;
    nap->leaderIndex = leaderIndex;
    d_sd->lp[nap->leaderIndex].leaderAgentIndex = cap->agentIndex;
		if (d_sd->leaderType == MixedLeader) {
      nap->leaderType = IndependentLeader;
		}

		glm::vec4 color = chooseLeaderColor(leaderIndex);
    nap->leaderID = nap->agentIndex;
		for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
			d_vfptr[i].culoare = color;
		}

    memcpy(cap, nap, sizeof(AgentProperties));

		d_sd->currentLeaders++;
	}
}

__global__ void leaderKernel(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, SimulationDetails* d_sd) {
	const unsigned int tid = threadIdx.x;
  if (tid == 1) {
    createRandomLeaders(d_a3pv, d_vfptr, d_sd, tid);
  }
}


void launchLeaderKernel(VertexFormat *dd_vfptr)
{
	dim3 gridLeaders(1);
	dim3 threadsLeaders(1);

	leaderKernel << < gridLeaders, threadsLeaders >> > ((Agent3DProperties *)dd_d3pv, dd_vfptr, (SimulationDetails *)dd_sd);
	cudaDeviceSynchronize();
}
