#include "Includes.cuh"

#pragma once

__device__ bool isMember(int* vector, int size, int member)
{
	for (int i = 0; i < size; i++) {
		if (vector[i] == member) {
			return true;
		}
	}
	return false;
}

__device__ bool isNeighborToLeader(Agent3DProperties* d_a3pv, SimulationDetails* d_sd, unsigned int tid)
{
  AgentProperties* cap = &d_a3pv[tid].currentProperties;
  AgentProperties* l_cap = &d_a3pv[cap->leaderID].currentProperties;
  if (glm::distance(cap->centerPosition, l_cap->centerPosition) < d_sd->modelSize * 3.5f) {
    return true;
  }
	return false;
}

__device__ void getNumberOfFollowersAndSwarmLimits(AgentProperties* cap, AgentProperties *nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  if (cap->isLeader && cap->leaderType != ShapeSubLeader) {
    d_sd->lp[cap->leaderIndex].followers = 0;
    d_sd->lp[cap->leaderIndex].allObstacleAgents = 0;
    float maxX = 0;
    float minX = 99999;
    float maxZ = 0;
    float minZ = 99999;

    for (int i = 0; i < d_sd->swarmSize; i++) {
      AgentProperties* f_cap = &d_a3pv[i].currentProperties;
      if (f_cap->agentIndex == cap->agentIndex) continue;
      if (f_cap->leaderID == cap->agentIndex) {
        d_sd->lp[cap->leaderIndex].followers++;
        d_sd->lp[cap->leaderIndex].allObstacleAgents += f_cap->numberOfObstacleAgents;
        if (maxX < f_cap->centerPosition.x) {
          maxX = f_cap->centerPosition.x;
        }

        if (minX > f_cap->centerPosition.x) {
          minX = f_cap->centerPosition.x;
        }
        if (maxZ < f_cap->centerPosition.y) {
          maxZ = f_cap->centerPosition.y;
        }

        if (minZ > f_cap->centerPosition.y) {
          minZ = f_cap->centerPosition.y;
        }
        if (f_cap->isLeader && f_cap->leaderType == ShapeSubLeader) {
          for (int j = 0; j < d_sd->swarmSize; j++) {
            AgentProperties* fj_cap = &d_a3pv[j].currentProperties;
            if (fj_cap->leaderID == f_cap->agentIndex) {
              d_sd->lp[cap->leaderIndex].followers++;
            }
          }
        }
      }
    }
    d_sd->lp[cap->leaderIndex].swarmLimitsX = glm::vec2(minX, maxX);
    d_sd->lp[cap->leaderIndex].swarmLimitsY = glm::vec2(minZ, maxZ);
  }
}

__device__ glm::vec2 avoidObstacles(ObstacleProperties * d_opv, SimulationDetails *d_sd, unsigned int tid)
{
	glm::vec2 ahead = d_opv[tid].centerPosition + d_opv[tid].speed * d_sd->obstacleSpeed;
	glm::vec2 avoidance(0, 0);

	glm::vec2 v2MaxZ = glm::vec2(d_opv[tid].centerPosition.x, d_sd->mapCoords.w);
	glm::vec2 v2MinZ = glm::vec2(d_opv[tid].centerPosition.x, d_sd->mapCoords.z);
	glm::vec2 v2MaxX = glm::vec2(d_sd->mapCoords.y, d_opv[tid].centerPosition.y);
	glm::vec2 v2MinX = glm::vec2(d_sd->mapCoords.x, d_opv[tid].centerPosition.y);


	if (glm::distance(v2MaxZ, ahead) < d_sd->obstacleSize) {
    return glm::normalize(ahead - v2MaxZ);
	}

	if (glm::distance(v2MinZ, ahead) < d_sd->obstacleSize) {
    return glm::normalize(ahead - v2MinZ);
	}

	if (glm::distance(v2MaxX, ahead) < d_sd->obstacleSize) {
    return glm::normalize(ahead - v2MaxX);
	}

	if (glm::distance(v2MinX, ahead) < d_sd->obstacleSize) {
    return glm::normalize(ahead - v2MinX);
	}
	return avoidance;
}

__device__ glm::vec2 getCenterPosition(Agent3DProperties* d_a3pv, VertexFormat* d_vfptr, SimulationDetails* d_sd, unsigned int tid) {
	glm::vec2 centerPosition = glm::vec2(0, 0);

	for (int i = tid * 4; i < tid * 4 + 4; i++) {
		centerPosition += glm::vec2(d_vfptr[i].pozitie.x, d_vfptr[i].pozitie.z);
	}
	return centerPosition / 4.0f;;
}

__device__ glm::vec2 getSwarmCenter(Agent3DProperties* d_a3pv, SimulationDetails * d_sd, unsigned int leaderId) {
	glm::vec2 center = glm::vec2();
	for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
		if (cap->leaderID == leaderId) {
			center += d_a3pv[i].currentProperties.centerPosition;
		}
	}
  float followers = d_sd->lp[d_a3pv[leaderId].currentProperties.leaderIndex].followers;
	return center / followers;
}


__device__ glm::vec4 getSwarmMargins(Agent3DProperties* d_a3pv, SimulationDetails * d_sd, unsigned int leaderId) {
  glm::vec4 swarmMargins = glm::vec4(99999, 0, 99999, 0);
  for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
    if (cap->leaderID == leaderId) {
      // Min X
      if (swarmMargins.x > cap->centerPosition.x) {
        swarmMargins.x = cap->centerPosition.x;
      }
      // Max X
      if (swarmMargins.y < cap->centerPosition.x) {
        swarmMargins.y = cap->centerPosition.x;
      }
      // Min z
      if (swarmMargins.z > cap->centerPosition.y) {
        swarmMargins.z = cap->centerPosition.y;
      }
      // Max z
      if (swarmMargins.w < cap->centerPosition.y) {
        swarmMargins.w = cap->centerPosition.y;
      }
    }
  }
  return swarmMargins;
}


__device__ glm::vec2 getSwarmSpeed(Agent3DProperties* d_a3pv, SimulationDetails * d_sd, unsigned int leaderId) {
  glm::vec2 speed = glm::vec2();
  for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* cap = &d_a3pv[i].currentProperties;
    if (cap->leaderID == leaderId) {
      speed += d_a3pv[i].currentProperties.speed;
    }
  }
  float followers = d_sd->lp[d_a3pv[leaderId].currentProperties.leaderIndex].followers;
  return speed / followers;
}

__device__ glm::vec4 chooseLeaderColor(int leaderNumber) {
	switch (leaderNumber) {
	case 0:
		// red
		return glm::vec4(1, 0, 0, 1);
	case 1:
		// green
		return glm::vec4(0, 1, 0, 1);
	case 2:
		// blue
		return glm::vec4(0, 0, 1, 1);
	case 3:
		// yellow
		return glm::vec4(1, 1, 0, 1);
	case 4:
		// magenta
		return glm::vec4(1, 0, 1, 1);
	case 5:
		// cyan
		return glm::vec4(0, 1, 1, 1);
	case 6:
		// orange
		return glm::vec4(1, 0.5, 0, 1);
	case 7:
		// dark green
		return glm::vec4(0, 0.2, 0, 1);
  case 8:
    // Aquamarine
    return glm::vec4(0.498, 1.000, 0.831, 1);
  case 9:
    // MediumSlateBlue
    return glm::vec4(0.482, 0.408, 0.933, 1);
  case 10:
    // Navy
    return glm::vec4(0.000, 0.000, 0.502, 1);
  case 11:
    // Peru
    return glm::vec4(0.804, 0.522, 0.247, 1);
  case 12:
    // Brown
    return glm::vec4(0.647, 0.165, 0.165, 1);
  case 13:
    // LawnGreen
    return glm::vec4(0.486, 0.988, 0.000, 1);
  case 14:
    // Crimson
    return glm::vec4(0.863, 0.078, 0.235, 1);
  case 15:
    // Tomato
    return glm::vec4(1.000, 0.388, 0.278, 1);
  case 16:
    // DarkKhaki
    return glm::vec4(0.741, 0.718, 0.420, 1);
  case 17:
    // RosyBrown
    return glm::vec4(0.737, 0.561, 0.561, 1);
  default:
    return glm::vec4(0, 0, 0, 1);
	}
}

__device__ void adoptLeaderColor(AgentProperties* nap, VertexFormat* d_vfptr, Agent3DProperties *d_a3pv)
{
  if (!nap->isLeader) {
    if (nap->leaderID >= 0) {
     /* if (!d_a3pv[nap->leaderID].newProperties.customColor) { //d_a3pv[nap->leaderID].currentProperties.state == FinishMovement) {
        for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
          d_vfptr[i].culoare = chooseLeaderColor(nap->color);
          //d_vfptr[i].culoare.a = 0.2;
        }
      } else */
      if (nap->customColor) {
        for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
          d_vfptr[i].culoare = chooseLeaderColor(nap->color);
          d_vfptr[i].culoare.a = 0.2;
        }
      }
      else if (d_a3pv[nap->leaderID].newProperties.customColor) {
        for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
          d_vfptr[i].culoare = chooseLeaderColor(d_a3pv[nap->leaderID].newProperties.color);
          d_vfptr[i].culoare.a = 0.2;
        }
      }
      else {
        for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
          d_vfptr[i].culoare = chooseLeaderColor(d_a3pv[nap->leaderID].newProperties.leaderIndex);
          d_vfptr[i].culoare.a = 0.2;
        }
      }
     
    }
    else {
      for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
        d_vfptr[i].culoare = glm::vec4(1, 1, 1, 1);
      }
    }
  }
  else if (nap->customColor) {
    for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
      d_vfptr[i].culoare = chooseLeaderColor(nap->color);
      d_vfptr[i].culoare.a = 0.2;
    }
  }
  else {
    if (nap->leaderType == ShapeSubLeader) {
      for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
        d_vfptr[i].culoare = chooseLeaderColor(nap->color);
      }
    }
    else {
      for (int i = nap->agentIndex * 4; i < nap->agentIndex * 4 + 4; i++) {
        d_vfptr[i].culoare = chooseLeaderColor(nap->leaderIndex);
      }
    }
  }
}

__device__ glm::vec2 chooseDirection(int discreteDirection)
{
  switch (discreteDirection) {
  case 0:
    return glm::vec2(-1, -1);
  case 1:
    return glm::vec2(-1, 0);
  case 2:
    return glm::vec2(-1, 1);
  case 3:
    return glm::vec2(0, -1);
  case 5:
    return glm::vec2(0, 1);
  case 6:
    return glm::vec2(1, -1);
  case 7:
    return glm::vec2(1, 0);
  case 8:
    return glm::vec2(1, 1);
  default:
    return glm::vec2(0, 0);
  }
}

__device__ glm::vec2 avoidObstacle(SimulationDetails *d_sd, glm::vec2 startSpeed, glm::vec2 startPosition, glm::vec2 obstaclePosition, float distanceMultiplier = 1) {
  glm::vec2 ahead = startPosition + startSpeed * d_sd->maxSpeed * distanceMultiplier;
  if (glm::distance(obstaclePosition, ahead) < d_sd->modelSize && (ahead - obstaclePosition != glm::vec2(0,0))) {
    return glm::normalize(ahead - obstaclePosition);
  }
  return glm::vec2(0, 0);
}

__device__ glm::vec2 maintainObjectDistance(SimulationDetails *d_sd, glm::vec2 startSpeed, glm::vec2 startPosition, glm::vec2 obstaclePosition, float distanceMultiplier = 1) {
  glm::vec2 ahead = startPosition + startSpeed * d_sd->maxSpeed * distanceMultiplier;
  if (glm::distance(obstaclePosition, ahead) > d_sd->neighborDistance) {
    return glm::normalize(obstaclePosition - ahead);
  }
  return glm::vec2(0, 0);
}

__device__ void setObstacleAvoidance(AgentProperties* cap, AgentProperties* nap, SimulationDetails *d_sd,  glm::vec2 avoidanceSpeed)
{
  if (avoidanceSpeed != glm::vec2(0, 0)) {
    if (!cap->isLeader) {
      nap->leaderID = -1;
    }
    else {
      d_sd->lp[cap->leaderIndex].shapeForming = false;

    }
    nap->collision = true;
    nap->speed = avoidanceSpeed;
  }
}

__device__ void setAgentAvoidance(AgentProperties* cap, AgentProperties* nap, glm::vec2 avoidanceSpeed, bool collision=false, glm::vec2 obstaclePosition=glm::vec2(0, 0))
{
  if (avoidanceSpeed != glm::vec2(0, 0)) {
    nap->avoidAgents = true;
    nap->avoidSpeed = avoidanceSpeed;
    if (collision) {
      nap->collision = true;
      nap->collisionType = 2;
      nap->obstaclePosition = obstaclePosition;
    }
  }
}

__device__ void avoidAgents(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails *d_sd, float distanceMultiplier = 1)
{
  for (int i = 0; i < cap->numberOfNeighbors; i++) {
    AgentProperties* n_cap = &d_a3pv[cap->neighborsList[i]].currentProperties;
    glm::vec2 avoidance = avoidObstacle(d_sd, nap->avoidSpeed, cap->centerPosition, n_cap->centerPosition, distanceMultiplier);
    setAgentAvoidance(cap, nap, avoidance);
  }
  //if (cap->leaderID == -1) {
    for (int i = 0; i < cap->numberOfObstacleAgents; i++) {
      if (cap->obstacleAgents[i] != -1) {
        AgentProperties* n_cap = &d_a3pv[cap->obstacleAgents[i]].currentProperties;
        glm::vec2 avoidance = avoidObstacle(d_sd, nap->avoidSpeed, cap->centerPosition, n_cap->centerPosition, distanceMultiplier);
        setAgentAvoidance(cap, nap, avoidance);
      }
    }
  //}
}

__device__ void maintainDistance(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails *d_sd, float distanceMultiplier = 1)
{
  for (int i = 0; i < cap->numberOfNeighbors; i++) {
    AgentProperties* n_cap = &d_a3pv[cap->neighborsList[i]].currentProperties;
    /*if ((!cap->shapeForming && !n_cap->shapeForming) ||
      (cap->shapeForming && n_cap->shapeForming) ||
      (!cap->shapeForming && n_cap->shapeForming)) {
      */
      glm::vec2 maintenanceSpeed = maintainObjectDistance(d_sd, nap->maintainSpeed, cap->centerPosition, n_cap->centerPosition, distanceMultiplier);
      if (maintenanceSpeed != glm::vec2(0, 0)) {
        nap->maintainSpeed = maintenanceSpeed;
      }
    /*}*/
  }
}

__device__ void chooseSimpleAgentSpeed(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  glm::vec2 leaderSpeed = glm::vec2(0, 0);

  nap->speed = cap->speed * 0.30f + cap->neighborMeanSpeed * 0.60f;

  if (cap->leaderID != -1) {
    AgentProperties* l_cap = &d_a3pv[cap->leaderID].currentProperties;
    nap->speed += l_cap->speed * 0.1f;

    if (l_cap->leaderType == ShapeSubLeader) {
      nap->speed = cap->speed * 0.5f + l_cap->speed * 0.5f;
    }
    else if (l_cap->state < 1) {
      nap->speed = glm::normalize(nap->speed);
    }
    else {
      nap->speed = cap->speed * 0.75f + cap->neighborMeanSpeed * 0.20f + l_cap->speed * 0.05f;
    }

    nap->avoidSpeed = nap->speed;
    nap->maintainSpeed = nap->speed;
    avoidAgents(cap, nap, d_a3pv, d_sd);
    if (cap->numberOfObstacleAgents > 0) {
      nap->speed = nap->avoidSpeed;
    }
    else {
      maintainDistance(cap, nap, d_a3pv, d_sd);
      nap->speed = nap->avoidSpeed * 0.95f + nap->maintainSpeed * 0.05f;
    }
  }
  else {
    nap->speed = glm::normalize(nap->speed);

    nap->avoidSpeed = nap->speed;
    nap->maintainSpeed = nap->speed;
    avoidAgents(cap, nap, d_a3pv, d_sd);
    maintainDistance(cap, nap, d_a3pv, d_sd);

    nap->speed = glm::normalize(nap->avoidSpeed * 0.95f + nap->maintainSpeed * 0.05f);
  }
}

__device__ bool avoidMargins(AgentProperties* cap, AgentProperties* nap, SimulationDetails *d_sd)
{
  nap->speed = cap->speed;
  glm::vec2 avoidance = avoidObstacle(d_sd, nap->speed, cap->centerPosition, glm::vec2(cap->centerPosition.x, d_sd->mapCoords.w));
  setObstacleAvoidance(cap, nap, d_sd, avoidance);
  avoidance = avoidObstacle(d_sd, nap->speed, cap->centerPosition, glm::vec2(cap->centerPosition.x, d_sd->mapCoords.z));
  setObstacleAvoidance(cap, nap, d_sd, avoidance);
  avoidance = avoidObstacle(d_sd, nap->speed, cap->centerPosition, glm::vec2(d_sd->mapCoords.y, cap->centerPosition.y));
  setObstacleAvoidance(cap, nap, d_sd, avoidance);
  avoidance = avoidObstacle(d_sd, nap->speed, cap->centerPosition, glm::vec2(d_sd->mapCoords.x, cap->centerPosition.y));
  setObstacleAvoidance(cap, nap, d_sd, avoidance);
  if (nap->collision) {
    return true;
  }
  return false;
}

__device__ void countCollisions(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, ObstacleProperties* d_opv, unsigned int tid)
{
  for (int i = 0; i < d_sd->numberOfObstacles; i++) {
    AgentProperties cap = d_a3pv[tid].currentProperties;
    if (glm::distance(d_opv[i].centerPosition, cap.centerPosition) < d_sd->obstacleSize / 2) {
      d_sd->collisions++;
    }
  }
}

__device__ int getLeaderId(AgentProperties* cap, Agent3DProperties* d_a3pv)
{
  if (cap->leaderID == -1) {
    return -1;
  }
  else {
    int leaderId = cap->leaderID;
    AgentProperties* l_cap = &d_a3pv[leaderId].currentProperties;
    while (leaderId != l_cap->leaderID && leaderId != -1) {
      leaderId = l_cap->leaderID;
      l_cap = &d_a3pv[leaderId].currentProperties;
    }

    return leaderId;
  }
}

__device__ bool shouldBeAdopted(AgentProperties* cap, AgentProperties* n_cap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  AgentProperties* l_cap = NULL;
  AgentProperties* ln_cap = NULL;
  if (getLeaderId(cap, d_a3pv) != -1) {
    l_cap = &d_a3pv[getLeaderId(cap, d_a3pv)].currentProperties;
  }

  if (getLeaderId(n_cap, d_a3pv) != -1) {
    ln_cap = &d_a3pv[getLeaderId(n_cap, d_a3pv)].currentProperties;
  }

  bool shouldBeAdopted = true;

  if (l_cap != NULL && ln_cap != NULL) {
    if (l_cap->leaderID == ln_cap->leaderID) {
      shouldBeAdopted = true;
    }
    else  if (!d_sd->lp[l_cap->leaderIndex].stillAdopting || !d_sd->lp[ln_cap->leaderIndex].stillAdopting) {
      shouldBeAdopted = false;
    }
  }

  if (l_cap != NULL && ln_cap == NULL) {
    if (!d_sd->lp[l_cap->leaderIndex].stillAdopting) {
      shouldBeAdopted = false;
    }
  }
  
  if (ln_cap != NULL && l_cap == NULL) {
    if (!d_sd->lp[ln_cap->leaderIndex].stillAdopting) {
      shouldBeAdopted = false;
    }
  }
  return shouldBeAdopted;
}


__device__ void getNeighbors(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  nap->numberOfNeighbors = 0;
  nap->numberOfObstacleAgents = 0;
  for (int i = 0; i < 1000; i++) {
    nap->neighborsList[i] = -1;
    nap->obstacleAgents[i] = -1;
  }

  glm::vec2 meanSpeed = glm::vec2(0, 0);
  if (!cap->collision) {
    for (int i = 0; i < d_sd->swarmSize; i++) {
      AgentProperties* n_cap = &d_a3pv[i].currentProperties;
      if (n_cap->agentIndex == cap->agentIndex) continue;
      if (glm::distance(cap->centerPosition, n_cap->centerPosition) < d_sd->neighborDistance) {
        //if (shouldBeAdopted(cap, n_cap, d_a3pv, d_sd)) {
          nap->neighborsList[nap->numberOfNeighbors] = n_cap->agentIndex;
          nap->numberOfNeighbors++;
          meanSpeed += n_cap->speed;
        //}
        //else {
        //  nap->obstacleAgents[nap->numberOfObstacleAgents] = n_cap->agentIndex;
        //  nap->numberOfObstacleAgents++;
        //}
      }
    }
  }
  if (nap->numberOfNeighbors > 0) {
    nap->neighborMeanSpeed = meanSpeed / static_cast<float>(nap->numberOfNeighbors);
  }
  else {
    nap->neighborMeanSpeed = glm::vec2(0, 0);
  }
  /*
  for (int i = 0; i < 9; i++) {
    nap->discreteNeighborsList[i] = 0;
  }

  for (int i = 0; i < nap->numberOfNeighbors; i++) 
  {
    int agentIndex = nap->neighborsList[i];

    AgentProperties* n_cap = &d_a3pv[agentIndex].currentProperties;
    if (glm::distance(n_cap->centerPosition, cap->centerPosition) < d_sd->modelSize) {
      glm::vec2 neighborPosition = n_cap->centerPosition;
      glm::vec2 agentPosition = cap->centerPosition;
      glm::vec2 distanceSign = glm::sign(neighborPosition - agentPosition);
      int positionX = 0;
      int positionY = 0;

      if (glm::distance(neighborPosition.x, agentPosition.x) < d_sd->modelSize) {
        positionX = 0;
      }
      else {
        positionX = distanceSign.x;
      }

      if (glm::distance(neighborPosition.y, agentPosition.y) < d_sd->modelSize) {
        positionY = 0;
      }
      else {
        positionY = distanceSign.y;
      }
     
      int matrixPosition = 4 + positionX * 3 + positionY;
      nap->discreteNeighborsList[matrixPosition] ++;
    }
  }
  */
}

__device__ bool hasSameLeader(AgentProperties* cap1, AgentProperties* cap2, Agent3DProperties* d_a3pv) {
  return d_a3pv[cap1->leaderID].currentProperties.leaderID == d_a3pv[cap2->leaderID].currentProperties.leaderID;
}

__device__ void resetLeader(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, int leaderID)
{
	for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* nap = &d_a3pv[i].newProperties;
		if (nap->leaderID == leaderID) {
      nap->leaderID = -1;
		}
	}
}

__device__ void resetLeaderFarthestAgents(Agent3DProperties* d_a3pv, SimulationDetails *d_sd, int leaderID, int noAgents)
{
  AgentProperties* l_cap = &d_a3pv[leaderID].currentProperties;
  for (int e = 0; e <= noAgents + 1; e++) {
    float maxDistance = 0;
    int agentIndex = 0;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      AgentProperties *cap = &d_a3pv[i].currentProperties;

      if (cap->leaderID == leaderID && i != leaderID) {
        if (glm::distance(cap->centerPosition, l_cap->centerPosition) > maxDistance) {
          maxDistance = glm::distance(cap->centerPosition, l_cap->centerPosition);
          agentIndex = i;
        }
      }
    }
    d_a3pv[agentIndex].newProperties.leaderID = -1;
  }
}

/* Some <math.h> files do not define M_PI... */
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

__device__ int circleFit(AgentProperties* cap, SimulationDetails* d_sd, Agent3DProperties* d_a3pv,
  float *centerPositionX, float *centerPositionY, float *circleRadius)
{

  if (d_sd->lp[cap->leaderIndex].followers > 10) {
    glm::vec2 agentPositions[2000];
    // int numberOfAgents = d_sd->lp[cap->leaderIndex].followers;

    int crtFollower = 0;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (i == cap->agentIndex) continue;
      AgentProperties* f_cap = &d_a3pv[i].currentProperties;

      if (f_cap->leaderID == cap->leaderID) {
        agentPositions[crtFollower] = f_cap->centerPosition;
        crtFollower++;
      }
      /*
      if (f_cap->isLeader && f_cap->leaderType == ShapeSubLeader) {
        for (int j = 0; j < d_sd->swarmSize; j++) {          
          AgentProperties* fj_cap = &d_a3pv[j].currentProperties;
          if (fj_cap->leaderID == cap->agentIndex) continue;
          if (fj_cap->leaderID == f_cap->agentIndex) {
            agentPositions[crtFollower] = fj_cap->centerPosition;
            crtFollower++;
          }
        }
      }
      */
    }

    const int maxIterations = 100;
    const float tolerance = 1e-06;

    float a, b, r;

    int i, j;
    float xAvr = 0.0;
    float yAvr = 0.0;

    for (i = 0; i < crtFollower; i++) {
      xAvr += agentPositions[i].x;
      yAvr += agentPositions[i].y;
    }
    xAvr /= (float) crtFollower;
    yAvr /= (float) crtFollower;

    a = xAvr;
    b = yAvr;
    
    for (j = 0; j < maxIterations; j++) {

      float a0 = a;
      float b0 = b;

      float LAvr = 0.0;
      float LaAvr = 0.0;
      float LbAvr = 0.0;
      
      for (i = 0; i < crtFollower; i++) {
        float dx = agentPositions[i].x - a;
        float dy = agentPositions[i].y - b;
        float L = sqrt(dx * dx + dy * dy);

        if (fabs(L) > tolerance) {
          LAvr += L;
          LaAvr -= dx / L;
          LbAvr -= dy / L;
        }
      }
      
      LAvr /= (float) crtFollower;
      LaAvr /= (float) crtFollower;
      LbAvr /= (float) crtFollower;

      a = xAvr + LAvr * LaAvr;
      b = yAvr + LAvr * LbAvr;
      r = LAvr;

      if (fabs(a - a0) <= tolerance && fabs(b - b0) <= tolerance)
        break;
    }
    

    *centerPositionX = a;
    *centerPositionY = b;
    *circleRadius = r;

    delete agentPositions;

    return (j < maxIterations ? j : -1);
  }
  return 0;
}

__device__ float signTriangle(glm::vec2 p1, glm::vec2 p2, glm::vec2 p3)
{
  return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

__device__ bool isPointInsideTriangle(glm::vec2 pt, glm::vec2 v1, glm::vec2 v2, glm::vec2 v3)
{
  bool b1, b2, b3;

  b1 = signTriangle(pt, v1, v2) < 0.0f;
  b2 = signTriangle(pt, v2, v3) < 0.0f;
  b3 = signTriangle(pt, v3, v1) < 0.0f;

  return ((b1 == b2) && (b2 == b3));
}