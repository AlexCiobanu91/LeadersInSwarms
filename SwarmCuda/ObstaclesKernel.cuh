#include "Includes.cuh"

#pragma once

__device__ void moveObstacle(ObstacleProperties* d_opv, VertexFormat* d_ovfptr, SimulationDetails *d_sd, unsigned int tid)
{
	glm::vec2 avoidContainerSpeed = avoidObstacles(d_opv, d_sd, tid);
	if (avoidContainerSpeed != glm::vec2()) {
		d_opv[tid].speed = avoidContainerSpeed;
	}

	d_opv[tid].centerPosition += d_opv[tid].speed * d_sd->obstacleSpeed;
	for (int i = tid * 4; i < tid * 4 + 4; i++) {
    glm::vec2 newPosition = d_opv[tid].speed * d_sd->obstacleSpeed;
    d_ovfptr[i].pozitie += glm::vec3(newPosition.x, 0, newPosition.y);
	}
}

__global__ void obstacleKernel(ObstacleProperties* d_opv, VertexFormat* d_ovfptr, SimulationDetails* d_sd)
{
	const unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < d_sd->numberOfObstacles) {
		moveObstacle(d_opv, d_ovfptr, d_sd, tid);
	}
}

void launchObstacleKernel(SimulationDetails* sd, bool dynamicObstacles, VertexFormat * dd_ovfptr)
{
	int num_threads = sd->numberOfObstacles;
	int grid = glm::max((int)ceil((float)num_threads / MaxThreadsPerBlock), 1);

	if (dynamicObstacles) {
		obstacleKernel << <grid, MaxThreadsPerBlock >> > ((ObstacleProperties *)dd_opv, dd_ovfptr, (SimulationDetails *)dd_sd);
		cudaDeviceSynchronize();
	}
}
