#include "Includes.cuh"

#pragma once

__device__ bool needsToSlowDownSwarm(AgentProperties* cap, SimulationDetails* d_sd)
{
  return glm::length(d_sd->lp[cap->leaderIndex].swarmSpeed) > 0.1;
}

__device__ void slowDownSwarm(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd) {
  nap->normalizeSpeed = false;
  nap->speed = d_sd->lp[cap->leaderIndex].swarmSpeed * 0.8f;
}

__device__ bool isLeaderAtCenter(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd, int whichCenter)
{
  glm::vec2 center = glm::vec2();
  glm::vec2 center1 = cap->centerPosition;
  switch (whichCenter) {
  case 1: // swarm
    center = d_sd->lp[cap->leaderIndex].swarmCenter;
    nap->slowSpeed = false;
    break;
  case 2: // environment
    center = d_sd->lp[cap->leaderIndex].shapeCenter;
    nap->slowSpeed = true;
    break;
  case 3: // both centers
    center = d_sd->lp[cap->leaderIndex].shapeCenter;
    center1 = d_sd->lp[cap->leaderIndex].swarmCenter;
  }
  return glm::distance(center, center1) < d_sd->modelSize * 3;
}

__device__ void moveLeaderToCenter(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd, Centers whichCenter, bool slow = false)
{
  glm::vec2 center = glm::vec2();
  glm::vec2 center1 = cap->centerPosition;
  switch (whichCenter) {
  case SwarmCenter:
    center = d_sd->lp[cap->leaderIndex].swarmCenter;
    nap->slowSpeed = false;
    break;
  case EnvCenter:
    center = d_sd->shapePositions[d_sd->lp[cap->leaderIndex].shapePosition];
    //center = d_sd->lp[cap->leaderIndex].shapeCenter;
    nap->slowSpeed = true;
    break;
  case BothCenters:
    center = d_sd->lp[cap->leaderIndex].shapeCenter;
    center1 = d_sd->lp[cap->leaderIndex].swarmCenter;
  }

  glm::vec2 swarmSpeed = d_sd->lp[cap->leaderIndex].swarmSpeed;
  if (glm::distance(center, center1) > 5) {
    glm::vec2 direction = glm::sign(center - center1);
    if (swarmSpeed.x < 0.2 || swarmSpeed.y < 0.2) {
      swarmSpeed = glm::vec2(0.2, 0.2);
    }
    nap->speed = glm::abs(swarmSpeed) * direction * 1.1f;
    if (nap->speed.x > 1.0f || nap->speed.y > 1.0f) {
      nap->speed = glm::normalize(nap->speed);
    }
    if (slow) {
      nap->speed = nap->speed / 10.f;
    }
  }
  else {
    nap->speed = glm::vec2(0, 0);
  }
}

__device__ glm::vec2 chooseDirection(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
  switch (d_sd->lp[cap->leaderIndex].currentShape)
  {
  case Square:
    switch (nap->direction % 4) {
    case 0: // D
      return glm::vec2(0, 1);
    case 1: // R
      return glm::vec2(1, 0);
    case 2: // U
      return glm::vec2(0, -1);
    case 3: // L
      return glm::vec2(-1, 0);
    default:
      return glm::vec2(0, 1);
    }

  case HorizontalLineLR:
  case HorizontalLineLR_HalfL:
  case HorizontalLineLR_HalfR:
    switch (nap->direction % 2) {
    case 0:
      return glm::vec2(1, 0);
    case 1:
      return glm::vec2(-1, 0);
    default:
      return glm::vec2(1, 0);
    }

  case HorizontalLineRL:
  case HorizontalLineRL_HalfL:
  case HorizontalLineRL_HalfR:
    switch (nap->direction % 2) {
    case 0:
      return glm::vec2(-1, 0);
    case 1:
      return glm::vec2(1, 0);
    default:
      return glm::vec2(-1, 0);
    }

  case VerticalLineUD:
  case VerticalLineUD_HalfU:
  case VerticalLineUD_HalfD:
    switch (nap->direction % 2) {
    case 0:
      return glm::vec2(0, 1);
    case 1:
      return glm::vec2(0, -1);
    default:
      return glm::vec2(0, 1);
    }

  case VerticalLineDU:
  case VerticalLineDU_HalfU:
  case VerticalLineDU_HalfD:
    switch (nap->direction % 2) {
    case 0:
      return glm::vec2(0, -1);
    case 1:
      return glm::vec2(0, 1);
    default:
      return glm::vec2(0, -1);
    }

  case MainDiagonalLR:
  case MainDiagonalLR_HalfL:
  case MainDiagonalLR_HalfR:
    switch (nap->direction % 2) {
    default:
    case 0:
      return glm::vec2(1, -1);
    case 1:
      return glm::vec2(-1, 1);
    }

  case MainDiagonalRL:
  case MainDiagonalRL_HalfL:
  case MainDiagonalRL_HalfR:
    switch (nap->direction % 2) {
    default:
    case 0:
      return glm::vec2(-1, 1);
    case 1:
      return glm::vec2(1, -1);
    }

  case AntiDiagonalLR:
  case AntiDiagonalLR_HalfL:
  case AntiDiagonalLR_HalfR:
    switch (nap->direction % 2) {
    default:
    case 0:
      return glm::vec2(1, 1);
    case 1:
      return glm::vec2(-1, -1);
    }

  case AntiDiagonalRL:
  case AntiDiagonalRL_HalfL:
  case AntiDiagonalRL_HalfR:
    switch (nap->direction % 2) {
    default:
    case 0:
      return glm::vec2(-1, -1);
    case 1:
      return glm::vec2(1, 1);
    }

  case Circle:
    float radians = glm::radians(static_cast<float>(nap->direction + nap->startAngle));
    return glm::normalize(glm::vec2(sin(radians), cos(radians)));
    // return glm::vec2(1, 1);

  case UserControlled:
    switch (nap->direction) {
    default:
    case 0: // U
      return glm::vec2(0, -1);
    case 1: // D
      return glm::vec2(0, 1);
    case 2: // R
      return glm::vec2(1, 0);
    case 3: // L
      return glm::vec2(-1, 0);
    case 10:
      return glm::vec2(0, 0);
    }
  }

  return glm::vec2(0, 0);
}

__device__ void changeMovementDirection(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
  bool changeDirection = false;
  glm::vec2 newCenterPosition = cap->centerPosition + cap->speed * 2.f * d_sd->maxSpeed;

  switch (d_sd->lp[cap->leaderIndex].currentShape) {
  case Square:
  case MainDiagonalLR:
  case MainDiagonalLR_HalfL:
  case MainDiagonalLR_HalfR:
  case MainDiagonalRL:
  case MainDiagonalRL_HalfL:
  case MainDiagonalRL_HalfR:
  case AntiDiagonalLR:
  case AntiDiagonalLR_HalfL:
  case AntiDiagonalLR_HalfR:
  case AntiDiagonalRL:
  case AntiDiagonalRL_HalfL:
  case AntiDiagonalRL_HalfR:

    if (newCenterPosition.x < cap->movementMargins.x ||
      newCenterPosition.x > cap->movementMargins.y ||
      newCenterPosition.y < cap->movementMargins.z ||
      newCenterPosition.y > cap->movementMargins.w) {
      changeDirection = true;
    }
    break;
  case HorizontalLineLR:
  case HorizontalLineRL:
  case HorizontalLineLR_HalfL:
  case HorizontalLineRL_HalfL:
  case HorizontalLineLR_HalfR:
  case HorizontalLineRL_HalfR:
    if (newCenterPosition.x < cap->movementMargins.x ||
      newCenterPosition.x > cap->movementMargins.y) {
      changeDirection = true;
    }
    break;

  case VerticalLineUD:
  case VerticalLineDU:
  case VerticalLineUD_HalfU:
  case VerticalLineDU_HalfU:
  case VerticalLineUD_HalfD:
  case VerticalLineDU_HalfD:
    if (newCenterPosition.y < cap->movementMargins.z ||
      newCenterPosition.y > cap->movementMargins.w) {
      changeDirection = true;
    }
    break;

  case Circle:
    changeDirection = true;
    break;
    /*
    case MainDiagonalLR_HalfL:
    case MainDiagonalRL_HalfL:
    case AntiDiagonalLR_HalfL:
    case AntiDiagonalRL_HalfL:
    nap->movementMargins = glm::vec4(swarmCenter.x - swarmX,
    swarmCenter.x + swarmX,
    swarmCenter.y - swarmY,
    swarmCenter.y + swarmY);
    break;

    case MainDiagonalLR_HalfR:
    case MainDiagonalRL_HalfR:
    case AntiDiagonalLR_HalfR:
    case AntiDiagonalRL_HalfR:
    nap->movementMargins = glm::vec4(swarmCenter.x - swarmX,
    swarmCenter.x + swarmX,
    swarmCenter.y - swarmY,
    swarmCenter.y + swarmY);
    break;
    */
  case UserControlled:
    nap->direction = d_sd->userDirection;
    break;
  }

  if (changeDirection /*|| cap->movementFrames > d_sd->movementFrames*/) {
    nap->movementFrames = 0;
    nap->direction = cap->direction + 1;
  }
  else {
    nap->movementFrames++;
  }


}

__device__ void computeMovementRadius(AgentProperties* cap, AgentProperties* nap, SimulationDetails *d_sd)
{
  if (cap->computeNewCenter) {
    glm::vec2 swarmCenter = d_sd->lp[cap->leaderIndex].swarmCenter;
    glm::vec4 swarmMargins = glm::vec4(d_sd->lp[cap->leaderIndex].swarmLimitsX.x, d_sd->lp[cap->leaderIndex].swarmLimitsX.y,
      d_sd->lp[cap->leaderIndex].swarmLimitsY.x, d_sd->lp[cap->leaderIndex].swarmLimitsY.y);

    float swarmX = glm::abs(swarmMargins.x - swarmMargins.y) * d_sd->movementPercentages.x;
    float swarmY = glm::abs(swarmMargins.z - swarmMargins.w) * d_sd->movementPercentages.y;

    nap->movementRadius = glm::vec2(swarmX, swarmY);

    switch (d_sd->lp[cap->leaderIndex].currentShape) {
    case Square:
    case MainDiagonalLR:
    case MainDiagonalRL:
    case AntiDiagonalLR:
    case AntiDiagonalRL:
      nap->movementMargins = glm::vec4(swarmCenter.x - swarmX,
        swarmCenter.x + swarmX,
        swarmCenter.y - swarmY,
        swarmCenter.y + swarmY);
      break;
    case HorizontalLineLR:
    case HorizontalLineRL:
      nap->movementMargins = glm::vec4(swarmCenter.x - swarmX, swarmCenter.x + swarmX, 0, 0);
      break;

    case HorizontalLineLR_HalfL:
    case HorizontalLineRL_HalfL:
      nap->movementMargins = glm::vec4(swarmCenter.x - (swarmX / 2.f), swarmCenter.x + swarmX, 0, 0);
      break;

    case HorizontalLineLR_HalfR:
    case HorizontalLineRL_HalfR:
      nap->movementMargins = glm::vec4(swarmCenter.x - swarmX, swarmCenter.x + (swarmX / 2.f), 0, 0);
      break;

    case VerticalLineUD:
    case VerticalLineDU:
      nap->movementMargins = glm::vec4(0, 0, swarmCenter.y - swarmY, swarmCenter.y + swarmY);
      break;

    case VerticalLineUD_HalfU:
    case VerticalLineDU_HalfU:
      nap->movementMargins = glm::vec4(0, 0, swarmCenter.y - swarmY, swarmCenter.y + (swarmY / 2.f));
      break;


    case VerticalLineUD_HalfD:
    case VerticalLineDU_HalfD:
      nap->movementMargins = glm::vec4(0, 0, swarmCenter.y - (swarmY / 2.f), swarmCenter.y + swarmY);
      break;

    case Circle:
      glm::vec2 swarmCenter = d_sd->lp[cap->leaderIndex].swarmCenter;
      float ipotenuse = glm::distance(swarmCenter, cap->centerPosition);
      glm::vec2 quadran = glm::sign(cap->centerPosition - swarmCenter);
      float angle = glm::degrees(asin(glm::distance(swarmCenter.x, cap->centerPosition.x) / ipotenuse));
      if (quadran.x >= 0) {
        // second quadran
        if (quadran.y >= 0) {
          angle += 90;
        }
        // first quadran
        else {
          angle += 0;
        }
      }
      else {
        // third quadran
        if (quadran.y >= 0) {
          angle += 90;
        }
        // fourth quadran
        else {
          angle += 270;
        }
      }
      nap->startAngle = angle;
      break;
      /*
      case MainDiagonalLR_HalfL:
      case MainDiagonalRL_HalfL:
      case AntiDiagonalLR_HalfL:
      case AntiDiagonalRL_HalfL:
      nap->movementMargins = glm::vec4(swarmCenter.x - swarmX,
      swarmCenter.x + swarmX,
      swarmCenter.y - swarmY,
      swarmCenter.y + swarmY);
      break;

      case MainDiagonalLR_HalfR:
      case MainDiagonalRL_HalfR:
      case AntiDiagonalLR_HalfR:
      case AntiDiagonalRL_HalfR:
      nap->movementMargins = glm::vec4(swarmCenter.x - swarmX,
      swarmCenter.x + swarmX,
      swarmCenter.y - swarmY,
      swarmCenter.y + swarmY);
      break;
      */
    }
    nap->computeNewCenter = false;
  }
  else {
    nap->movementMargins = cap->movementMargins;
  }
}

__device__ bool isShapeMovementPerformed(AgentProperties* cap, SimulationDetails* d_sd)
{
  int iterations = INF;
  switch (d_sd->lp[cap->leaderIndex].currentShape) {
  case Square: iterations = SquareIterations; break;
  case HorizontalLineLR:
  case HorizontalLineRL:
  case HorizontalLineLR_HalfL:
  case HorizontalLineRL_HalfL:
  case HorizontalLineLR_HalfR:
  case HorizontalLineRL_HalfR: iterations = HorizontalLineIterations; break;
  case VerticalLineUD:
  case VerticalLineDU:
  case VerticalLineUD_HalfU:
  case VerticalLineDU_HalfU:
  case VerticalLineUD_HalfD:
  case VerticalLineDU_HalfD: iterations = VerticalLineIterations; break;
  case MainDiagonalLR:
  case MainDiagonalLR_HalfL:
  case MainDiagonalLR_HalfR:
  case MainDiagonalRL:
  case MainDiagonalRL_HalfL:
  case MainDiagonalRL_HalfR:
  case AntiDiagonalLR:
  case AntiDiagonalLR_HalfL:
  case AntiDiagonalLR_HalfR:
  case AntiDiagonalRL:
  case AntiDiagonalRL_HalfL:
  case AntiDiagonalRL_HalfR: iterations = DiagonalIterations; break;
  case Circle: iterations = CircleIterations * 4; break;
  case UserControlled: return !d_sd->userControlled;
  }
  return cap->direction >= iterations;
}

__device__ void moveInShape(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
  computeMovementRadius(cap, nap, d_sd);
  changeMovementDirection(cap, nap, d_sd);
  nap->speed = chooseDirection(cap, nap, d_sd);
}

__device__ bool checkNumberOfFollowers(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd, float lowerLimit, float UpperLimit) {
  return d_sd->lp[cap->leaderIndex].followers >= lowerLimit /* &&  d_sd->lp[cap->leaderIndex].followers <= UpperLimit*/;
}

__device__ void setShapeFormingFollowers(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd, bool reset = false)
{/*
  if (!reset) {
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (d_a3pv[i].currentProperties.leaderID == cap->leaderID) {
        d_a3pv[i].newProperties.shapeForming = true;
      }
    }
  }
  else {
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (d_a3pv[i].currentProperties.leaderID == cap->leaderID) {
        d_a3pv[i].newProperties.shapeForming = false;
      }
    }
  }
  */
}

__device__ void chooseNewLeaderShape(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd) {

  if (d_sd->userControlled) {
    d_sd->lp[cap->leaderIndex].currentShape = UserControlled;
  }
  else {
    curandState state;
    curand_init((unsigned long long)clock() + cap->agentIndex, 0, 0, &state);
    float myrandf = curand_uniform(&state);
    myrandf *= (25 + 0.999999);
    int shape = static_cast<int>(truncf(myrandf));
    d_sd->lp[cap->leaderIndex].currentShape = static_cast<MovementShapes>(shape);
  }

  /*switch (cap->shape) {
  case Square:
  nap->shape = VerticalLineDU_HalfU;
  break;
  case HorizontalLineRL:
  nap->shape = VerticalLineDU;
  break;
  case VerticalLineDU:
  nap->shape = HorizontalLineRL_HalfL;
  break;
  case HorizontalLineRL_HalfL:
  nap->shape = VerticalLineDU_HalfU;
  break;
  }*/
}

__device__ glm::vec2 getGroupOrientation(int groupNumber) {
  switch (groupNumber) {
  case 0: return glm::vec2(-1, -1);
  case 3: return glm::vec2(-1, 1);
  case 12: return glm::vec2(1, -1);
  case 15: return glm::vec2(1, 1);
  }
  return glm::vec2(0, 0);
}

__device__ glm::vec2 getGroupOrientationByIndex(int index) {
  switch (index) {
  case 0: return glm::vec2(-1, -1);
  case 1: return glm::vec2(-1, 1);
  case 2: return glm::vec2(1, -1);
  case 3: return glm::vec2(1, 1);
  }
  return glm::vec2(0, 0);
}

__device__ void createCircleSubLeaders(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd)
{
  for (int j = 0; j < 4; j++) {
    int smallestHeartBeat = 999999;
    int farthestAgent = 9999;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (i == cap->agentIndex) continue;
      AgentProperties * a_cap = &d_a3pv[i].currentProperties;
      AgentProperties * a_nap = &d_a3pv[i].newProperties;
      if (a_cap->heartbeat < smallestHeartBeat &&
        a_cap->leaderID == cap->leaderID &&
        !a_cap->isLeader && !a_nap->isLeader) {
        smallestHeartBeat = a_cap->heartbeat;
        farthestAgent = a_cap->agentIndex;
      }
    }
    if (farthestAgent < d_sd->swarmSize) {
      AgentProperties * a_cap = &d_a3pv[farthestAgent].currentProperties;
      AgentProperties * a_nap = &d_a3pv[farthestAgent].newProperties;

      a_nap->isLeader = true;
      a_nap->leaderType = ShapeSubLeader;
      a_nap->state = GatherFollowersState;
      glm::vec2 leaderPosition = cap->centerPosition;
      glm::vec2 agentPosition = a_cap->centerPosition;
      glm::vec2 speed = glm::normalize(leaderPosition - agentPosition);
      a_nap->speed = speed;
      a_nap->leaderFrames = 0;
      a_nap->customColor = true;
      a_nap->color = d_sd->noLeaders + cap->leaderIndex;
      d_sd->lp[cap->leaderIndex].hasSubLeaders = true;
      d_sd->lp[cap->leaderIndex].subLeaders++;
      // return;
    }
  }
}

__device__ bool goneTooFar(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd, MovementShapes shape) 
{
  int nShape = (int)shape;
  switch (nShape) {
  case Square:
    float dist = 0;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (i == cap->agentIndex) continue;
      AgentProperties * a_cap = &d_a3pv[i].currentProperties;
      AgentProperties * a_nap = &d_a3pv[i].newProperties;
      if (a_cap->leaderID == cap->agentIndex &&
        !a_cap->isLeader && !a_nap->isLeader) {
        glm::vec2 leaderPosition = cap->centerPosition;
        glm::vec2 agentPosition = a_cap->centerPosition;

        if (glm::distance(leaderPosition, agentPosition) > dist) {
          dist = glm::distance(leaderPosition, agentPosition);
          d_sd->lp[cap->leaderIndex].farthestAgent = i;
          d_sd->lp[cap->leaderIndex].farthestAgentPosition = a_cap->centerPosition;
        }
      }
    }
    if (d_sd->noLeaders > 2) {
      return dist > 1600;
    }
    else {
      return dist > 2650;
    }
  case Triangle:
    float distBase = 0;
    float distHeight = 0;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (i == cap->agentIndex) continue;
      AgentProperties * a_cap = &d_a3pv[i].currentProperties;
      AgentProperties * a_nap = &d_a3pv[i].newProperties;
      if (a_cap->leaderID == cap->agentIndex &&
        !a_cap->isLeader && !a_nap->isLeader) {
        glm::vec2 leaderPosition = cap->centerPosition;
        glm::vec2 agentPosition = a_cap->centerPosition;

        if (glm::distance(leaderPosition.x, agentPosition.x) > distBase) {
          distBase = glm::distance(leaderPosition, agentPosition);
        }

        if (glm::distance(leaderPosition.y, agentPosition.y) > distHeight) {
          distHeight = glm::distance(leaderPosition, agentPosition);
        }
      }
    }
    return distBase > 2600 || distHeight > 1300;
  }
  return false;
}

__device__ void createTriangleSubLeaders(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd)
{
  float base = 8500;
  float height = 4000;
  if (d_sd->noLeaders > 2) {
    base = 4800;
    height = 2800;
  }

  glm::vec2 t_a = glm::vec2(cap->centerPosition.x - base / 2, cap->centerPosition.y - height / 2);
  glm::vec2 t_b = glm::vec2(cap->centerPosition.x + base / 2, cap->centerPosition.y - height / 2);
  glm::vec2 t_c = glm::vec2(cap->centerPosition.x, cap->centerPosition.y + height / 2);

  //bool inwards = goneTooFar(cap, nap, d_a3pv, d_sd, Triangle);
  //if (inwards) {

  for (int j = 0; j < 4; j++) {
    int smallestHeartBeat = 99999;
    int farthestAgent = 9999;
    glm::vec2 orientation = getGroupOrientationByIndex(j);
    for (int i = 0; i < d_sd->swarmSize; i++) {
      if (i == cap->agentIndex) continue;
      AgentProperties * a_cap = &d_a3pv[i].currentProperties;
      AgentProperties * a_nap = &d_a3pv[i].newProperties;
      if (a_cap->heartbeat < smallestHeartBeat &&
        a_cap->leaderID == cap->agentIndex &&
        !a_cap->isLeader && !a_nap->isLeader &&
        !isPointInsideTriangle(a_cap->centerPosition, t_a, t_b, t_c) &&
        glm::sign(a_cap->centerPosition - cap->centerPosition) == orientation) {
        smallestHeartBeat = a_cap->heartbeat;
        farthestAgent = a_cap->agentIndex;
      }
    }

    if (farthestAgent < d_sd->swarmSize) {
      AgentProperties * a_cap = &d_a3pv[farthestAgent].currentProperties;
      AgentProperties * a_nap = &d_a3pv[farthestAgent].newProperties;

      a_nap->isLeader = true;
      a_nap->leaderType = ShapeSubLeader;
      a_nap->state = GatherFollowersState;
      glm::vec2 leaderPosition = cap->centerPosition;
      glm::vec2 agentPosition = a_cap->centerPosition;
      glm::vec2 speed = glm::normalize(leaderPosition - agentPosition) ;
      a_nap->speed = speed;
      a_nap->leaderFrames = 0;
      a_nap->customColor = true;
      a_nap->color = 4;
      d_sd->lp[cap->leaderIndex].hasSubLeaders = true;
      d_sd->lp[cap->leaderIndex].subLeaders++;
    }
  }
}

__device__ void createSquareSubLeaders(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd, float numberOfGroups = 16)
{
  bool inwards = false;
  inwards = goneTooFar(cap, nap, d_a3pv, d_sd, Square);
  if (!inwards) {
    for (int j = 0; j < d_sd->lp[cap->leaderIndex].numberOfShapeGroups; j++) {
      float currentGroup = d_sd->lp[cap->leaderIndex].shapeGroups[j];
      glm::vec2 groupOrientation = getGroupOrientation(currentGroup);

      float numberOfSubgroups = 4;
      float separationStep = numberOfGroups / numberOfSubgroups;

      glm::vec2 groupSteps = glm::vec2(glm::distance(d_sd->lp[cap->leaderIndex].swarmLimitsX.x, 
                                                    d_sd->lp[cap->leaderIndex].swarmLimitsX.y), 
                                       glm::distance(d_sd->lp[cap->leaderIndex].swarmLimitsY.x, 
                                                    d_sd->lp[cap->leaderIndex].swarmLimitsY.y));
      groupSteps = groupSteps / separationStep;
      glm::vec2 startSwarmStep = glm::vec2(d_sd->lp[cap->leaderIndex].swarmLimitsX.x + groupSteps.x, 
                                           d_sd->lp[cap->leaderIndex].swarmLimitsY.x + groupSteps.y);

      int currentX = j / static_cast<int>(numberOfSubgroups);
      int currentY = j % static_cast<int>(numberOfSubgroups);

      glm::vec2 crtSwarmStep = startSwarmStep + glm::vec2(groupSteps.x * currentX, groupSteps.y * currentY);
      glm::vec2 groupMiddle = glm::vec2((crtSwarmStep.x - groupSteps.x + crtSwarmStep.x) / 2,
        (crtSwarmStep.y - groupSteps.y + crtSwarmStep.y) / 2);


      glm::vec2 groupMeanPosition = glm::vec2(0, 0);
      int groupMembers = 0;

      for (int i = 0; i < d_sd->swarmSize; i++) {
        if (i == cap->agentIndex) continue;
        AgentProperties * a_cap = &d_a3pv[i].currentProperties;
        AgentProperties * a_nap = &d_a3pv[i].newProperties;
        if (a_cap->leaderID == cap->agentIndex && !a_cap->isLeader && !a_nap->isLeader && a_cap->shapeGroupID == currentGroup) {
          groupMeanPosition += a_cap->centerPosition;
          groupMembers++;
        }
      }

      groupMeanPosition /= groupMembers;

      if (glm::distance(groupMeanPosition, groupMiddle) > 50) {

        int biggestHeartBeat = 0;
        int closestNeighbor = 9999;
        for (int i = 0; i < d_sd->swarmSize; i++) {
          if (i == cap->agentIndex) continue;
          AgentProperties * a_cap = &d_a3pv[i].currentProperties;
          AgentProperties * a_nap = &d_a3pv[i].newProperties;
          if (a_cap->heartbeat > biggestHeartBeat &&
            a_cap->leaderID == cap->agentIndex &&
            !a_cap->isLeader && !a_nap->isLeader &&
            a_cap->heartbeat <= cap->heartbeat - 4 &&
            glm::sign(a_cap->centerPosition - cap->centerPosition) == groupOrientation) {
            biggestHeartBeat = a_cap->heartbeat;
            closestNeighbor = a_cap->agentIndex;
          }
        }
        if (closestNeighbor < d_sd->swarmSize) {
          AgentProperties * a_cap = &d_a3pv[closestNeighbor].currentProperties;
          AgentProperties * a_nap = &d_a3pv[closestNeighbor].newProperties;

          a_nap->isLeader = true;
          a_nap->leaderType = ShapeSubLeader;
          a_nap->state = GatherFollowersState;
          glm::vec2 leaderPosition = cap->centerPosition;
          glm::vec2 agentPosition = a_cap->centerPosition;
          glm::vec2 speed = glm::normalize(groupMeanPosition - agentPosition) * 0.5f;
          a_nap->speed = speed;
          a_nap->leaderFrames = 0;
          a_nap->customColor = true;
          a_nap->color = d_sd->noLeaders + cap->leaderIndex;
          d_sd->lp[cap->leaderIndex].hasSubLeaders = true;
          d_sd->lp[cap->leaderIndex].subLeaders++;
        }
      }
    }
  }
  else {
    for (int j = 0; j < 4; j++) {
      int smallestHeartBeat = 999999;
      int farthestAgent = 9999;
      for (int i = 0; i < d_sd->swarmSize; i++) {
        if (i == cap->agentIndex) continue;
        AgentProperties * a_cap = &d_a3pv[i].currentProperties;
        AgentProperties * a_nap = &d_a3pv[i].newProperties;
        if (a_cap->heartbeat < smallestHeartBeat &&
          a_cap->leaderID == cap->agentIndex &&
          !a_cap->isLeader && !a_nap->isLeader) {
          smallestHeartBeat = a_cap->heartbeat;
          farthestAgent = a_cap->agentIndex;
        }
      }
      if (farthestAgent < d_sd->swarmSize) {
        AgentProperties * a_cap = &d_a3pv[farthestAgent].currentProperties;
        AgentProperties * a_nap = &d_a3pv[farthestAgent].newProperties;

        a_nap->isLeader = true;
        a_nap->leaderType = ShapeSubLeader;
        a_nap->state = GatherFollowersState;
        glm::vec2 leaderPosition = cap->centerPosition;
        glm::vec2 agentPosition = a_cap->centerPosition;
        glm::vec2 speed = glm::normalize(leaderPosition - agentPosition) * 0.4f;
        a_nap->speed = speed;
        a_nap->leaderFrames = 0;
        a_nap->customColor = true;
        a_nap->color = d_sd->noLeaders + cap->leaderIndex;
        d_sd->lp[cap->leaderIndex].hasSubLeaders = true;
        d_sd->lp[cap->leaderIndex].subLeaders++;
      }
    }
  }
}

__device__ void createSubleaders(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd)
{
  switch (d_sd->lp[cap->leaderIndex].currentShape) {
  case Circle:
    createCircleSubLeaders(cap, nap, d_a3pv, d_sd);
    break;
  case Square:
    createSquareSubLeaders(cap, nap, d_a3pv, d_sd);
    break;
  case Triangle:
    createTriangleSubLeaders(cap, nap, d_a3pv, d_sd);
  }
}

__device__ bool areThereAnySubLeaders(AgentProperties* cap, SimulationDetails* d_sd) {
  return d_sd->lp[cap->leaderIndex].hasSubLeaders;
}

__device__ bool swarmNotMoving(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails* d_sd)
{
  bool noMovements = true;
  for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* sl_cap = &d_a3pv[i].currentProperties;
    if (sl_cap->leaderID >= 0 && glm::distance(sl_cap->previousCenterPosition, sl_cap->centerPosition) > 10) {
      noMovements = false;
      break;
    }
  }
  if (d_sd->lp[cap->leaderIndex].currentShape == Circle || d_sd->lp[cap->leaderIndex].currentShape == Triangle) {
    return true;
  }
  return noMovements;
}

__device__ bool haveSubLeadersFinished(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails* d_sd) {
  
  for (int i = 0; i < d_sd->swarmSize; i++) {
    AgentProperties* sl_cap = &d_a3pv[i].currentProperties;
    if (sl_cap->agentIndex == cap->agentIndex) continue;
    if (sl_cap->leaderID == cap->agentIndex && sl_cap->leaderType == ShapeSubLeader) {
      if (sl_cap->leaderFrames >= d_sd->subLeaderLifeTime) {
        AgentProperties* sl_nap = &d_a3pv[i].newProperties;
        sl_nap->isLeader = false;
        sl_nap->leaderFrames = 0;
        sl_nap->speed = glm::vec2(0, 0);
        sl_nap->customColor = false;
        d_sd->lp[cap->leaderIndex].subLeaders--;
        for (int j = 0; j < d_sd->swarmSize; j++) {
          if (d_a3pv[j].currentProperties.leaderID == sl_cap->agentIndex) {
            d_a3pv[j].newProperties.leaderID = cap->leaderID;
          }
        }
      }
    }
  }
  if (d_sd->lp[cap->leaderIndex].subLeaders <= 0) {
    d_sd->lp[cap->leaderIndex].subLeaders = 0;
    d_sd->lp[cap->leaderIndex].hasSubLeaders = false;
  }
  return d_sd->lp[cap->leaderIndex].subLeaders == 0;
}

__device__ bool isShapeFormed(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails* d_sd)
{
  switch (d_sd->lp[cap->leaderIndex].currentShape) {
  case Circle:
    float circleRadius = d_sd->lp[cap->leaderIndex].circleRadius;
    float targetRadius = d_sd->circleRadiusTarget + d_sd->targetThreshold *  d_sd->circleRadiusTarget;
    glm::vec2 leaderCenter = cap->centerPosition;
    glm::vec2 circleCenter = glm::vec2(d_sd->lp[cap->leaderIndex].circleCenterX, d_sd->lp[cap->leaderIndex].circleCenterY);

    if (circleRadius <= targetRadius && glm::distance(leaderCenter, circleCenter) < 100) {
      return true;
    }
    return false;

  case Square:
    d_sd->lp[cap->leaderIndex].farAgents = -1;
    float squareSize = d_sd->circleRadiusTarget * sqrtf(2);

    float swarmHeight = glm::distance(d_sd->lp[cap->leaderIndex].swarmLimitsY.x, 
                                      d_sd->lp[cap->leaderIndex].swarmLimitsY.y);
    float swarmWidth = glm::distance(d_sd->lp[cap->leaderIndex].swarmLimitsX.x, 
                                     d_sd->lp[cap->leaderIndex].swarmLimitsX.y);

    bool equalHeightWidth = glm::distance(swarmHeight, swarmWidth) < 150;
    bool isHeightOk = glm::distance(swarmHeight, squareSize) < 50;
    bool isWidthOk = glm::distance(swarmHeight, squareSize) < 50;
    
    int cornerAgents = 0;
    for (int i = 0; i < d_sd->swarmSize; i++) {
      AgentProperties* f_cap = &d_a3pv[i].currentProperties;
      if (f_cap->agentIndex == cap->agentIndex) continue;
      if (f_cap->leaderID == cap->agentIndex) {
        float leaderDist = glm::distance(f_cap->centerPosition, cap->centerPosition);
        if (glm::distance(leaderDist, squareSize) < 25) {
          cornerAgents++;        
        }
      }
    }
    d_sd->lp[cap->leaderIndex].farAgents = cornerAgents;
    return equalHeightWidth && isHeightOk && isWidthOk && cornerAgents > 25;
  case Triangle:
    return false;
  }
  return false;
}

__device__ void populatePositionMatrix(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails * d_sd) {
  if (cap->isLeader) {
    nap->matrix_position = (d_sd->position_radius / 2) * d_sd->position_radius + (d_sd->position_radius / 2) - 20;
  }
  else if (cap->leaderID >= 0) {
    glm::vec2 agentPosition = cap->centerPosition;
    glm::vec2 leaderPosition = d_a3pv[cap->leaderID].currentProperties.centerPosition;

    glm::vec2 distance = glm::abs(leaderPosition - agentPosition);
    glm::vec2 sign_vec = glm::sign(leaderPosition - agentPosition);

    int centerPosition = (d_sd->position_radius / 2) * d_sd->position_radius + (d_sd->position_radius / 2);

    glm::vec2 position = (distance / d_sd->modelSize) * sign_vec;

    int matrixPosition = centerPosition + static_cast<int>(position.x) * d_sd->position_radius + static_cast<int>(position.y);

    nap->matrix_position = matrixPosition;
  }
  else {
    nap->matrix_position = -1;
  }
}

__device__ void generatePositionMatrix(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd)
{
  for (int i = 0; i < 10; i++) {
    d_sd->position_matrix[cap->agentIndex * 10 + i] = 0;
  }

  __syncthreads();
  populatePositionMatrix(cap, nap, d_a3pv, d_sd);
  __syncthreads();

  if (cap->agentIndex == 0) {
    for (int i = 0; i < d_sd->swarmSize; i++) {
      AgentProperties* nap = &d_a3pv[i].newProperties;
      if (-1 < nap->matrix_position < 10000) {
        d_sd->position_matrix[nap->matrix_position] ++;
      }
    }
  }
  __syncthreads();
}


__device__ void chooseBestShapePosition(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails * d_sd)
{
  for (int j = 0; j < d_sd->noLeaders; j++) {
    d_sd->shapePositionsChosen[j] = false;
  }

  for (int j = 0; j < d_sd->noLeaders; j++) {
    AgentProperties * l_cap = &d_a3pv[j].currentProperties;
    int currentShapePosition = 0;
    glm::vec2 leaderPosition = l_cap->centerPosition;
    float minDistance = glm::distance(leaderPosition, d_sd->shapePositions[currentShapePosition]);
    for (int i = 1; i < d_sd->noLeaders; i++) {
      if (minDistance > glm::distance(leaderPosition, d_sd->shapePositions[i]) && d_sd->shapePositionsChosen[i] == false) {
        minDistance = glm::distance(leaderPosition, d_sd->shapePositions[i]);
        currentShapePosition = i;
      }
    }

    d_sd->shapePositionsChosen[currentShapePosition] = true;
    d_sd->lp[l_cap->leaderIndex].shapePosition = currentShapePosition;
  }
}