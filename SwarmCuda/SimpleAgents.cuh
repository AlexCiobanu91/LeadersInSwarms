#include "Includes.cuh"
#include "ShapeKernel.cuh"
#include "LeadersKernel.cuh"
#pragma once
__device__ void resetCollision(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
  if (cap->collision) {

    if (cap->collisionType == 2) {
      if (glm::distance(cap->centerPosition, cap->obstaclePosition) > d_sd->modelSize * 20)
        nap->collision = false;
    }
    else {
      glm::vec2 v2MaxZ = glm::vec2(cap->centerPosition.x, d_sd->mapCoords.w);
      glm::vec2 v2MinZ = glm::vec2(cap->centerPosition.x, d_sd->mapCoords.z);
      glm::vec2 v2MaxX = glm::vec2(d_sd->mapCoords.y, cap->centerPosition.y);
      glm::vec2 v2MinX = glm::vec2(d_sd->mapCoords.x, cap->centerPosition.y);

      if (glm::distance(v2MaxZ, cap->centerPosition) > d_sd->modelSize * 5 &&
        glm::distance(v2MinZ, cap->centerPosition) > d_sd->modelSize * 5 &&
        glm::distance(v2MaxX, cap->centerPosition) > d_sd->modelSize * 5 &&
        glm::distance(v2MinX, cap->centerPosition) > d_sd->modelSize * 5) {
        nap->collision = false;
      }
    }
  }
}

__device__ void resetAvoidanceLeader(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid);
__device__ glm::vec2 createAvoidanceLeaders(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid);

__device__ glm::vec2 avoidObstacles(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid)
{
  AgentProperties* cap = &d_a3pv[tid].currentProperties;
  AgentProperties* nap = &d_a3pv[tid].newProperties;

	glm::vec2 avoidance(0, 0);
	if ((d_sd->avoidanceType == AvoidanceLeader && cap->isLeader)
		|| d_sd->avoidanceType == AvoidanceAll
		|| d_sd->leaderType == MixedLeader
		|| d_sd->leaderType == MixedLeaderCollisionEmerge) {

		glm::vec2 ahead = cap->centerPosition + cap->speed * d_sd->maxSpeed;

		for (int i = 0; i < d_sd->numberOfObstacles; i++) {
			if (glm::distance(d_opv[i].centerPosition, ahead) < d_sd->obstacleSize) {
				if (!cap->isLeader) {
          nap->leaderID = -1;
				}
				return glm::normalize(ahead - d_opv[i].centerPosition);
			}
		}
	}
	return avoidance;
}

__device__ bool computeCollisions(AgentProperties* cap, AgentProperties* nap, ObstacleProperties* d_opv, SimulationDetails *d_sd)
{
	resetCollision(cap, nap, d_sd);

	// resetAvoidanceLeader(d_a3pv, d_sd, d_opv, tid);

  if (avoidMargins(cap, nap, d_sd)) return true;
  /*
	avoidance = avoidObstacles(d_a3pv, d_sd, d_opv, tid);
	if (avoidance != glm::vec2(0, 0, 0)) {
		return avoidance;
	}

	avoidance = createAvoidanceLeaders(d_a3pv, d_vfptr, d_sd, d_opv, tid);
	if (avoidance != glm::vec2(0, 0, 0)) {
		return avoidance;
	}
	countCollisions(d_a3pv, d_sd, d_opv, tid);
  */
	return false;
}

__device__ glm::vec2 createAvoidanceLeaders(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid)
{
  AgentProperties* cap = &d_a3pv[tid].currentProperties;
  AgentProperties* nap = &d_a3pv[tid].newProperties;

	glm::vec2 avoidance(0, 0);
	if ((d_sd->leaderType == AvoidanceEmergeLeader || d_sd->leaderType == MixedLeaderCollisionEmerge)
		&& !cap->isLeader /* && d_sd->currentLeaders < d_sd->noLeaders */)
	{
		glm::vec2 ahead = cap->centerPosition + cap->speed * 10.f;

		for (int i = 0; i < d_sd->numberOfObstacles; i++) {
			if (glm::distance(d_opv[i].centerPosition, ahead) < d_sd->obstacleSize * 1.41) {
				d_sd->currentLeaders++;
        nap->isLeader = true;
        nap->leaderID = cap->agentIndex;
        nap->objectCollision = true;
        nap->obstacleID = i;
        nap->leaderType = d_sd->leaderType;

				d_vfptr[cap->agentIndex * 4 + 0].culoare = glm::vec4(0, 0, 0, 1);
				d_vfptr[cap->agentIndex * 4 + 1].culoare = glm::vec4(0, 0, 0, 1);

        return glm::normalize(ahead - d_opv[i].centerPosition);
			}
		}
	}
	return avoidance;
}

__device__ void resetAvoidanceLeader(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid)
{
  AgentProperties* cap = &d_a3pv[tid].currentProperties;
  AgentProperties* nap = &d_a3pv[tid].newProperties;
	
  if ((cap->leaderType == MixedLeaderCollisionEmerge || cap->leaderType == AvoidanceEmergeLeader) && cap->isLeader) {
		if (cap->objectCollision) {
			if (glm::distance(d_opv[cap->obstacleID].centerPosition, cap->centerPosition) > d_sd->modelSize * 15) {
        nap->objectCollision = false;
        nap->obstacleID = -1;
        nap->isLeader = false;
        nap->leaderType = -1;
				resetLeader(d_a3pv, d_sd, cap->agentIndex);
				d_sd->currentLeaders--;
			}
		}
	}
}

__device__ void chooseLeaderSpeed(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails *d_sd)
{
  if (d_sd->avoidanceType == AvoidanceEmerge) {
    nap->speed = glm::normalize(nap->speed);
  }
  else if (cap->leaderType == MotivationLeader ||
    cap->leaderType == CenterMotivationLeader ||
    cap->leaderType == BorderMotivationLeader) {

    d_sd->lp[cap->leaderIndex].framesMotivation ++;

    // float followersThreshold = ((float)cap->numberOfFollowers / d_sd->swarmSize);
    // glm::vec2 repositionSpeed = calculateRepositionDirection(cap, nap);
    glm::vec2 swarmSpeed = d_sd->lp[cap->leaderIndex].swarmSpeed;
    glm::vec2 swarmCenter = d_sd->lp[cap->leaderIndex].swarmCenter;


    if (glm::distance(cap->centerPosition, swarmCenter) > d_sd->modelSize * 2) {
      nap->speed = swarmCenter - cap->centerPosition;
    }
    else {
      nap->speed = swarmSpeed;
    }

    // glm::sign(d_sd->swarmSpeeds[cap->leaderIndex]);
    //newSpeed *= followersThreshold;
    /*
    if (cap->neighborMeanSpeed != glm::vec2(0, 0)) {
      newSpeed = cap->neighborMeanSpeed * (1.0f - followersThreshold) + leaderSpeed * followersThreshold;
    }
    else {
      newSpeed = cap->speed * (1.0f - followersThreshold) + leaderSpeed * followersThreshold;
    }
    */
    nap->speed = glm::normalize(nap->speed);
  }
  else if (cap->leaderType != ShapeSubLeader) {
    d_sd->lp[cap->leaderIndex].framesIndependent ++;
    nap->speed = glm::sign(cap->speed);
  }
  else if (cap->leaderType == ShapeSubLeader) {
    AgentProperties *l_cap = &d_a3pv[cap->leaderID].currentProperties;
    if (d_sd->lp[l_cap->leaderIndex].currentShape == Circle || d_sd->lp[l_cap->leaderIndex].currentShape == Triangle) {
      glm::vec2 leaderPosition = d_a3pv[cap->leaderID].currentProperties.centerPosition;
      glm::vec2 speed = glm::normalize(leaderPosition - cap->centerPosition);
      nap->speed = speed;
    }
    else {
      nap->speed = cap->speed;
    }
  }
}

__device__ void consumeEnergy(AgentProperties* cap, AgentProperties* nap, SimulationDetails *d_sd)
{
	if (d_sd->lp[cap->leaderIndex].energyPerLeader < 0) {
		d_sd->lp[cap->leaderIndex].energyPerLeader = d_sd->energyQuantity;

		if (cap->leaderType == IndependentLeader) {
			d_sd->lp[cap->leaderIndex].energyIBorrow ++;
		}

		if (cap->leaderType == MotivationLeader) {
			d_sd->lp[cap->leaderIndex].energyMBorrow ++;
		}
	}

  glm::vec2 currentSpeed = cap->speed * d_sd->maxSpeed;
	if (cap->leaderType == IndependentLeader) {	
		d_sd->lp[cap->leaderIndex].energyPerLeader -= (glm::length(currentSpeed) * d_sd->energyPercentPerFrame) / 100.;
		d_sd->lp[cap->leaderIndex].energyConsumedI += (glm::length(currentSpeed) * d_sd->energyPercentPerFrame) / 100.;
	}
	else
	{
		float followersThreshold = ((float)d_sd->lp[cap->leaderIndex].followers / d_sd->swarmSize);

		float leaderEnergy = (glm::length(currentSpeed) * (1.0 - followersThreshold) * d_sd->energyPercentPerFrame) / 100.;
		float followersEnergy = (glm::length(currentSpeed) * followersThreshold * d_sd->energyPercentPerFrame) / 100.;

		d_sd->lp[cap->leaderIndex].energyPerLeader += followersEnergy - leaderEnergy;
		d_sd->lp[cap->leaderIndex].energyConsumedM += -followersEnergy + leaderEnergy;
	}
}

__device__ void updateSpeed(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, ObstacleProperties* d_opv, SimulationDetails *d_sd)
{
  if (!computeCollisions(cap, nap, d_opv, d_sd) && !cap->collision) {
    if (cap->isLeader && cap->state == GatherFollowersState) {
      chooseLeaderSpeed(cap, nap, d_a3pv, d_sd);
    }
    else if (!cap->isLeader) {
      chooseSimpleAgentSpeed(cap, nap, d_a3pv, d_sd);
    }
  }

  if (d_sd->simulationType == EnergySimulation && cap->isLeader) {
    consumeEnergy(cap, nap, d_sd);
  }
}

__device__ void adoptAgents(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  if (!cap->collision && !cap->isLeader) {
    bool atLeast2Leaders = false;
    bool neighborToLeader = false;
    int* neighborsWithLeader = (int*)malloc(d_sd->noLeaders * sizeof(int));
    int noNeighborsWithLeader = 0;
    for (int i = 0; i < d_sd->noLeaders; i++) {
      neighborsWithLeader[i] = 0;
    }

    for (int i = 0; i < cap->numberOfNeighbors; i++) {
      int agentIndex = cap->neighborsList[i];
      AgentProperties* n_cap = &d_a3pv[agentIndex].currentProperties;
      if (n_cap->isLeader) {       
        if (n_cap->leaderType == ShapeSubLeader) {
          nap->leaderID = n_cap->agentIndex;
          free(neighborsWithLeader);
          return;
        }
        else if (!neighborToLeader) {
          nap->leaderID = n_cap->leaderID;
          neighborToLeader = true;
        }
      }
      else if (glm::distance(n_cap->centerPosition, cap->centerPosition) < (d_sd->neighborDistance * 5/6)  && n_cap->agentAdopting  &&  n_cap->leaderID >= 0 /* && (!n_cap->shapeForming || (n_cap->shapeForming && cap->shapeForming))*/ ) {
        AgentProperties* l_n_cap = &d_a3pv[n_cap->leaderID].currentProperties;
        noNeighborsWithLeader++;
        neighborsWithLeader[l_n_cap->leaderIndex] ++;
      }
    }

    if (neighborToLeader) {
      free(neighborsWithLeader);
      return;
    }

    int leaderID = -1;
    
    int maxNeighbors = 0;
    for (int i = 0; i < d_sd->noLeaders; i++) {
      if (neighborsWithLeader[i] > maxNeighbors) {
        maxNeighbors = neighborsWithLeader[i];
        leaderID = d_sd->lp[i].leaderAgentIndex;
      }
    }
    if (maxNeighbors > 0) {
      if (atLeast2Leaders) {
        if (cap->leaderID != leaderID) {
          nap->leaderID = leaderID;
        }
      }
      else if (noNeighborsWithLeader == cap->numberOfNeighbors || noNeighborsWithLeader >= 2) {
        nap->leaderID = leaderID;
      }
    }
    free(neighborsWithLeader);
  }
}

__device__ void changeLeaderType(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
	if (cap->isLeader && cap->leaderType != ShapeSubLeader) {
		if (d_sd->leaderType == MixedLeader) {
			if (d_sd->lp[cap->leaderIndex].followers < static_cast<float>(d_sd->swarmSize) * 0.05) {
        nap->leaderType = IndependentLeader;
			}
			else {
        nap->leaderType = MotivationLeader;
			}
		}
	}
}

__device__ void checkIfInsideObstacleArea(Agent3DProperties* d_a3pv, ObstacleProperties* d_opv, VertexFormat* d_vfptr, SimulationDetails* d_sd, unsigned int tid)
{
  AgentProperties* cap = &d_a3pv[tid].currentProperties;
	glm::vec2 agentPosition = cap->centerPosition;

	for (int i = 0; i < d_sd->numberOfObstacles; i++) {
		if (glm::distance(d_opv[i].centerPosition, agentPosition) < d_sd->influenceArea) {
			d_sd->agentsInObstacleArea[d_opv[i].index] ++;
		}
	}
}

__device__ void updateAgentPosition(AgentProperties* cap, AgentProperties* nap, VertexFormat* d_vfptr, SimulationDetails* d_sd)
{
  glm::vec2 newspeed = cap->centerPosition;
  if (cap->avoidAgents) {
    newspeed *= d_sd->maxSpeed / 2;
  }
  else {
    newspeed *= d_sd->maxSpeed;
  }
  nap->previousCenterPosition = cap->centerPosition;
  nap->centerPosition = cap->centerPosition + cap->speed * d_sd->maxSpeed;
  for (int i = cap->agentIndex * 4; i < cap->agentIndex * 4 + 4; i++) {
    glm::vec2 newPosition = cap->speed * d_sd->maxSpeed;
    d_vfptr[i].pozitie += glm::vec3(newPosition.x, 0, newPosition.y);
  }
}

__device__ void heartbeat(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  if (cap->isLeader && cap->leaderType != ShapeSubLeader) {
    nap->heartbeat = cap->heartbeat + 1;
  } 
  else if (cap->leaderID >= 0) {
    int newHeartbeat = 0;
    for (int i = 0; i < cap->numberOfNeighbors; i++) {
      AgentProperties* n_cap = &d_a3pv[cap->neighborsList[i]].currentProperties;
      if (n_cap->heartbeat > newHeartbeat) {
        if (hasSameLeader(cap, n_cap, d_a3pv)) {
          newHeartbeat = n_cap->heartbeat;
        } 
      }
    }
    
    if (newHeartbeat > cap->heartbeat) {
      nap->separatedTimer = 0;
      nap->heartbeat = newHeartbeat;
      nap->agentAdopting = true;
    }
    else if (cap->separatedTimer < d_sd->separationThreshold) {
      nap->agentAdopting = false;
      nap->separatedTimer = cap->separatedTimer + 1;
    }
    else {
      nap->leaderID = -1;
      nap->separatedTimer = 0;
      nap->heartbeat = 0;
      nap->agentAdopting = true;
    }
  }
}

__device__ void updateLeaderFrames(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd) {
  if (cap->isLeader && cap->leaderType == ShapeSubLeader) {
    nap->leaderFrames++;
    d_sd->lp[cap->leaderIndex].leaderFrames = nap->leaderFrames;
    d_sd->lp[cap->leaderIndex].leaderSubSpeed = cap->speed;
  }
}

__device__ void updateLeaderPositionMatrix(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr_pm, AgentProperties *cap, AgentProperties *nap, SimulationDetails * d_sd) {
  glm::vec2 leaderPosition = nap->centerPosition;

  int maxVertex = d_sd->position_radius * 4;
  int iter = 0;
  for (int i = 0; i <= maxVertex; i += 4) {  
    glm::vec2 squareMean = glm::vec2(0, 0);
    for (int j = i; j < i + 4; j++) {
      squareMean += glm::vec2(d_vfptr_pm[j].pozitie.x, d_vfptr_pm[j].pozitie.z);
    }
    squareMean /= 4;
    glm::vec2 distanceVec = leaderPosition - squareMean;
    float halfRadius = d_sd->position_radius / 2;
    float threshold = halfRadius - i / 4;
    for (int j = i; j < i + 4; j++) {
      d_vfptr_pm[j].pozitie += glm::vec3(distanceVec.x - threshold * d_sd->modelSize, 0, distanceVec.y);
    }
    iter += 4;
  }


  for (int i = iter; i <= iter + maxVertex; i += 4) {
    glm::vec2 squareMean = glm::vec2(0, 0);
    for (int j = i; j < i + 4; j++) {
      squareMean += glm::vec2(d_vfptr_pm[j].pozitie.x, d_vfptr_pm[j].pozitie.z);
    }
    squareMean /= 4;
    glm::vec2 distanceVec = leaderPosition - squareMean;
    float halfRadius = d_sd->position_radius / 2;
    float threshold = halfRadius - (i - maxVertex) / 4;
    for (int j = i; j < i + 4; j++) {
      d_vfptr_pm[j].pozitie += glm::vec3(distanceVec.x, 0, distanceVec.y - threshold * d_sd->modelSize);
    }

    // glm::vec2 vertexPosition = 

    // 
    // glm::vec3 newPosition = glm::vec3(vertexPosition.x + distanceVec.x + d_sd->modelSize * (halfRadius - i), 0, vertexPosition.y);
    // d_vfptr_pm[j].pozitie = glm::vec3(0, 0, 0);
  }







}

__device__ void assignSubGroup(AgentProperties* nap, glm::vec2 diffPosition, int startGroup = 0, int color = 0) {
  if (diffPosition.y >= 0) {
    if (diffPosition.x <= 0) {
      nap->color = color;
      nap->shapeGroupID = startGroup;
    }
    else {
      nap->color = color;
      nap->shapeGroupID = startGroup;
    }
  }
  else {
    if (diffPosition.x >= 0) {
      nap->color = color;
      nap->shapeGroupID = startGroup;
    }
    else {
      nap->color = color;
      nap->shapeGroupID = startGroup;
    }
  }
  // nap->customColor = true;
}

__device__ void calculateRelativePosition(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails * d_sd, float numberOfGroups = 4) {
  if (cap->leaderID >= 0 && !cap->isLeader) {
    AgentProperties *l_cap = &d_a3pv[cap->leaderID].currentProperties;
    glm::vec2 agentPosition = cap->centerPosition;

    float numberOfSubgroups = 4;
    float separationStep = numberOfGroups / numberOfSubgroups;

    glm::vec2 groupSteps = glm::vec2(glm::distance(d_sd->lp[l_cap->leaderIndex].swarmLimitsX.x,
                                                   d_sd->lp[l_cap->leaderIndex].swarmLimitsX.y),
                                     glm::distance(d_sd->lp[l_cap->leaderIndex].swarmLimitsY.x,
                                                   d_sd->lp[l_cap->leaderIndex].swarmLimitsY.y));
    groupSteps = groupSteps / separationStep;
    glm::vec2 startSwarmStep = glm::vec2(d_sd->lp[l_cap->leaderIndex].swarmLimitsX.x + groupSteps.x,
                                         d_sd->lp[l_cap->leaderIndex].swarmLimitsY.x + groupSteps.y);

    for (int i = 0; i < sqrt(numberOfGroups); i++) {
      for (int j = 0; j < sqrt(numberOfGroups); j++) {
        glm::vec2 crtSwarmStep = startSwarmStep + glm::vec2(groupSteps.x * i, groupSteps.y * j);
        bool fitsX = (agentPosition.x >= crtSwarmStep.x - groupSteps.x) && (agentPosition.x < crtSwarmStep.x);
        bool fitsY = (agentPosition.y >= crtSwarmStep.y - groupSteps.y) && (agentPosition.y < crtSwarmStep.y);
        if (fitsX && fitsY) {
          glm::vec2 diffPosition = agentPosition - (crtSwarmStep / 2.0f);
          assignSubGroup(nap, diffPosition, i * 4 + j, i * 4 + j);
        }
      }
    }
  }
}

__global__ void updateKernel(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, ObstacleProperties* d_opv, SimulationDetails* d_sd) {
  const unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;
  if (tid == 0 && d_sd->currentLeaders < d_sd->noLeaders) {
    createRandomLeaders(d_a3pv, d_vfptr, d_sd, tid);
  }

  __syncthreads();

  if (tid < d_sd->swarmSize) {

    AgentProperties* cap = &d_a3pv[tid].currentProperties;
    AgentProperties* nap = &d_a3pv[tid].newProperties;

    getNumberOfFollowersAndSwarmLimits(cap, nap, d_a3pv, d_sd);

    getNeighbors(cap, nap, d_a3pv, d_sd);
    updateSpeed(cap, nap, d_a3pv, d_opv, d_sd);
    updateAgentPosition(cap, nap, d_vfptr, d_sd);
    updateLeaderFrames(cap, nap, d_sd);
    // checkIfInsideObstacleArea(d_a3pv, d_opv, d_vfptr, d_sd, tid);
    
    adoptAgents(cap, nap, d_a3pv, d_sd);
    heartbeat(cap, nap, d_a3pv, d_sd);
    changeLeaderType(cap, nap, d_sd);
    
    calculateRelativePosition(cap, nap, d_a3pv, d_sd, 16);
    __syncthreads();

    if (d_sd->shapeForming && cap->isLeader && cap->leaderType != ShapeSubLeader) {     
        changeBehavior(cap, nap, d_a3pv, d_sd);
        if (d_sd->noFrames % 20 == 0) {
          circleFit(cap, d_sd, d_a3pv,
            &d_sd->lp[cap->leaderIndex].circleCenterX,
            &d_sd->lp[cap->leaderIndex].circleCenterY,
            &d_sd->lp[cap->leaderIndex].circleRadius);
        }       
    }
    
    __syncthreads();

    
    adoptLeaderColor(nap, d_vfptr, d_a3pv);

    memcpy(cap, nap, sizeof(AgentProperties));
  }

  __syncthreads();

  if (tid < d_sd->noLeaders) {

    AgentProperties* cap = &d_a3pv[tid].currentProperties;

    d_sd->lp[cap->leaderIndex].swarmCenter = getSwarmCenter(d_a3pv, d_sd, tid);
    d_sd->lp[cap->leaderIndex].swarmSpeed = getSwarmSpeed(d_a3pv, d_sd, tid);
    d_sd->lp[cap->leaderIndex].leaderPosition = cap->centerPosition;
    d_sd->lp[cap->leaderIndex].leaderSpeed = cap->speed;

    d_sd->lp[cap->leaderIndex].leaderDirection = cap->direction;
    d_sd->lp[cap->leaderIndex].leaderMovementFrames = cap->movementFrames;
    d_sd->lp[cap->leaderIndex].movementRadius = cap->movementRadius;
    d_sd->lp[cap->leaderIndex].heartbeat = cap->heartbeat;
  }
  __syncthreads();
}

__global__ void relocatePositionMatrixKernel(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr_pm, SimulationDetails* d_sd) {
  const unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;
  if (tid == 0) {
    AgentProperties *cap = &d_a3pv[d_sd->lp[0].leaderAgentIndex].currentProperties;
    AgentProperties *nap = &d_a3pv[d_sd->lp[0].leaderAgentIndex].newProperties;
    updateLeaderPositionMatrix(d_a3pv, d_vfptr_pm, cap, nap, d_sd);
  }
}