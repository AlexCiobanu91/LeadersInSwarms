#include "Includes.cuh"
#include "Constants.cuh"
#include "ResearchKernel.cuh"
#include "ObstaclesKernel.cuh"
#include "SimpleAgents.cuh"
#include "LeadersKernel.cuh"

void sendData(std::string fis, Agent3DProperties* a3dpv, ObstacleProperties* opv, SimulationDetails* sd, 
			  GLuint agentVbo, GLuint obstaclesVbo, GLuint positionMatrixVbo)
{
	const int d3pv_size = sizeof(Agent3DProperties) * sd->swarmSize;
	const int sd_size = sizeof(SimulationDetails);
	const int rd_size = sizeof(ResearchDetails);
	const int d_osize = sizeof(ObstacleProperties) * sd->numberOfObstacles;
	const int f_size = sizeof(Frames);

	rd = new ResearchDetails();
	frames = new Frames();
	frames->frames = 0;

	cudaMalloc((Frames**)&dd_frames, f_size);
	cudaMalloc((Agent3DProperties**)&dd_d3pv, d3pv_size);
	cudaMalloc((SimulationDetails**)&dd_sd, sd_size);
	cudaMalloc((ResearchDetails**)&dd_rd, rd_size);
	cudaMalloc((ObstacleProperties**)&dd_opv, d_osize);

	// copy host memory to device
	cudaMemcpy(dd_frames, frames, f_size, cudaMemcpyHostToDevice);
	cudaMemcpy(dd_d3pv, a3dpv, d3pv_size, cudaMemcpyHostToDevice);
	cudaMemcpy(dd_opv, opv, d_osize, cudaMemcpyHostToDevice);
	cudaMemcpy(dd_sd, sd, sd_size, cudaMemcpyHostToDevice);
	cudaMemcpy(dd_rd, rd, rd_size, cudaMemcpyHostToDevice);

	cudaGraphicsGLRegisterBuffer(&obstacleResource, obstaclesVbo, cudaGraphicsMapFlagsNone);
	cudaGraphicsGLRegisterBuffer(&agentsResource, agentVbo, cudaGraphicsMapFlagsNone);
  cudaGraphicsGLRegisterBuffer(&positionMatrixResource, positionMatrixVbo, cudaGraphicsMapFlagsNone);

	InitFiles(fis);
}

 
void launchUpdateKernel(SimulationDetails* sd)
{
  size_t num_bytes;
  VertexFormat *dd_vfptr;
  //VertexFormat *dd_vfptr_pm;
  int num_threads = sd->swarmSize;
  int grid = glm::max((int)ceil((float)num_threads / MaxThreadsPerBlock), 1);

  cudaGraphicsMapResources(1, &agentsResource, 0);
  cudaGraphicsResourceGetMappedPointer((void **)&dd_vfptr, &num_bytes, agentsResource);

  updateKernel << <grid, MaxThreadsPerBlock >> > ((Agent3DProperties *)dd_d3pv, (VertexFormat *)dd_vfptr, (ObstacleProperties *)dd_opv, (SimulationDetails *)dd_sd);
  cudaDeviceSynchronize();

  cudaGraphicsUnmapResources(1, &agentsResource, 0);
}

void launchObstacleKernel(bool dynamicObstacles, SimulationDetails* sd) {
	VertexFormat *dd_ovfptr;
	size_t num_bytes;

	cudaGraphicsMapResources(1, &obstacleResource, 0);
	cudaGraphicsResourceGetMappedPointer((void **)&dd_ovfptr, &num_bytes, obstacleResource);

	launchObstacleKernel(sd, dynamicObstacles, dd_ovfptr);

	cudaGraphicsUnmapResources(1, &obstacleResource, 0);
}

void launchRelocatePositionMatrixKernel(SimulationDetails* sd) 
{
  size_t num_bytes;
  VertexFormat *dd_vfptr_pm;
  int num_threads = sd->swarmSize;
  int grid = glm::max((int)ceil((float)num_threads / MaxThreadsPerBlock), 1);

  cudaGraphicsMapResources(1, &positionMatrixResource, 0);
  cudaGraphicsResourceGetMappedPointer((void **)&dd_vfptr_pm, &num_bytes, positionMatrixResource);

  relocatePositionMatrixKernel << <grid, MaxThreadsPerBlock >> > ((Agent3DProperties *)dd_d3pv, (VertexFormat *)dd_vfptr_pm,  (SimulationDetails *)dd_sd);
  cudaDeviceSynchronize();

  cudaGraphicsUnmapResources(1, &positionMatrixResource, 0);
}

extern "C" bool runMotivationLeader(const int argc, const char **argv, std::string fis, Agent3DProperties* a3dpv, ObstacleProperties* opv, SimulationDetails* sd, 
	bool dataSent, GLuint agentVbo, GLuint obstaclesVbo, GLuint positionMatrixVbo, bool dynamicObstacles, bool freeMemory = false) {

	if (freeMemory) {

    cudaFree(dd_frames);
    cudaFree(dd_d3pv);
    cudaFree(dd_sd);
    cudaFree(dd_rd);
    cudaFree(dd_opv);

		closeFiles();
		cudaThreadExit();
	}
	
	if (sd != NULL && a3dpv != NULL && opv != NULL) {
		if (!dataSent) {
			sendData(fis, a3dpv, opv, sd, agentVbo, obstaclesVbo, positionMatrixVbo);
    }
    else {
      const int sd_size = sizeof(SimulationDetails);
      cudaMemcpy(dd_sd, sd, sd_size, cudaMemcpyHostToDevice);
    }

		launchUpdateKernel(sd);
    // launchRelocatePositionMatrixKernel(sd);
		// launchObstacleKernel(dynamicObstacles, sd);
    cudaMemcpy(sd, dd_sd, sizeof(SimulationDetails), cudaMemcpyDeviceToHost);

		// launchResearchKernel(sd);		

    
	}
	
	return true;
}
