#include "Includes.cuh"
#include "CommonFunctions.cuh"
#include "Constants.cuh"
#include "ShapeUtilityMethods.cuh"

#pragma once
__device__ LeaderStates changeNewStateFromPrevState(AgentProperties* cap, SimulationDetails* d_sd)
{
  switch (cap->previousState) {
  case GatherFollowersState: return MoveToEnvCenterState;
  case MoveToSwarmCenterState: return MoveToEnvCenterState;
  case MoveToEnvCenterState: return CreateSubLeaders;
  case ShapeMovementState: return CreateSubLeaders;
  case CreateSubLeaders: return WaitForSubLeaders;
    //////////// single shape forming leader /////////////
    // case ShapeMovementState: return ChooseShapeState;
    //////////////////////////////////////////////////////
  }
  return SlowDownState;
}

__device__ bool changeLeaderState(AgentProperties* cap, AgentProperties* nap, Agent3DProperties * d_a3pv, SimulationDetails* d_sd)
{
  switch (cap->state) {
  case GatherFollowersState: nap->state = SlowDownState; return true;
  case MoveToSwarmCenterState:
    if (isLeaderAtCenter(cap, nap, d_sd, SwarmCenter)) {
      nap->state = SlowDownState;
      return true;
    }
    break;
  case MoveToEnvCenterState:
    if (isLeaderAtCenter(cap, nap, d_sd, EnvCenter)) {
      nap->state = SlowDownState;
      return true;
    }
    break;
  case ShapeMovementState:
    if (isShapeMovementPerformed(cap, d_sd)) {
      nap->state = SlowDownState;
      return true;
    }
    break;
  case SlowDownState:
    if (!needsToSlowDownSwarm(cap, d_sd)) {
      nap->state = changeNewStateFromPrevState(cap, d_sd);
      return true;
    }
    break;
  case ChooseShapeState:
    chooseNewLeaderShape(cap, nap, d_sd);
    if (!isLeaderAtCenter(cap, nap, d_sd, EnvCenter)) {
      nap->state = MoveToEnvCenterState;
    }
    else {
      nap->state = ShapeMovementState;
    }
    break;
  case CreateSubLeaders:
    if (areThereAnySubLeaders(cap, d_sd)) {
      nap->state = WaitForSubLeaders;
      return true;
    }
    break;
  case WaitForSubLeaders:
    if (haveSubLeadersFinished(cap, nap, d_a3pv, d_sd) /* && swarmNotMoving(cap, nap, d_a3pv, d_sd) */ ) {
      if (isShapeFormed(cap, nap, d_a3pv, d_sd)) {
        if (d_sd->lp[cap->leaderIndex].initialShape) {
          nap->state = SwitchShape;
        }
        else {
          nap->state = FinishMovement;
        }
      }
      else {
        nap->state = CreateSubLeaders;
      }
      return true;
    }
    break;
  case SwitchShape:
    nap->state = CreateSubLeaders;
    return true;
    break;
  case FinishMovement:
    nap->state = FinishMovement;
    break;
  }
  
  return false;
}

__device__ void setStateProperties(AgentProperties* cap, AgentProperties* nap, SimulationDetails* d_sd)
{
  switch (nap->state) {
  case GatherFollowersState:
    d_sd->lp[cap->leaderIndex].currentShape = HorizontalLineRL;
    d_sd->lp[cap->leaderIndex].initialShape = true;
    break;
  case SlowDownState:
    break;
  case MoveToSwarmCenterState:
    break;
  case MoveToEnvCenterState:
    break;
  case ShapeMovementState:
    nap->movementFrames = 0;
    nap->computeNewCenter = true;
    nap->direction = 0;
    if (d_sd->imposedShape) {
      d_sd->lp[cap->leaderIndex].currentShape = d_sd->moveShape;
    }
    else {
      d_sd->lp[cap->leaderIndex].currentShape = UserControlled;
    }
    break;
  case ChooseShapeState:
    break;
  case CreateSubLeaders:
  case CreateSquareSubLeaders:
    if (!d_sd->lp[cap->leaderIndex].initialShape) {
      d_sd->lp[cap->leaderIndex].currentShape = d_sd->lp[cap->leaderIndex].targetShape;
    }
    nap->speed = glm::vec2(0, 0);
    d_sd->lp[cap->leaderIndex].hasSubLeaders = false;
    break;
  case WaitForSubLeaders:
    nap->speed = glm::vec2(0, 0);
    break;
  case SwitchShape:
    if (d_sd->lp[cap->leaderIndex].initialShape) {
      d_sd->lp[cap->leaderIndex].initialShape = false;
    }
    nap->speed = glm::vec2(0, 0);
    break;
  case FinishMovement:
    nap->speed = glm::vec2(0, 0);
    break;
  case UserControlled:
    nap->direction = d_sd->userDirection;
  }
}

__device__ void performStateBehavior(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails* d_sd)
{
  switch (cap->state) {
  case GatherFollowersState: 
    setShapeFormingFollowers(cap, nap, d_a3pv, d_sd, false); 
    break;
  case SlowDownState: slowDownSwarm(cap, nap, d_sd); break;
  case MoveToSwarmCenterState: 
    moveLeaderToCenter(cap, nap, d_sd, SwarmCenter); 
    break;
  case MoveToEnvCenterState: 
    moveLeaderToCenter(cap, nap, d_sd, EnvCenter); break;
  case ShapeMovementState: moveInShape(cap, nap, d_sd); break;
  // case ChooseShapeState: chooseNewLeaderShape(cap, nap, d_sd); break;
  case CreateSubLeaders: 
  case CreateSquareSubLeaders:
    createSubleaders(cap, nap, d_a3pv, d_sd); 
    //moveLeaderToCenter(cap, nap, d_sd, EnvCenter, true);
    break;
  case WaitForSubLeaders:
  case SwitchShape:
  case FinishMovement: 
    /*moveLeaderToCenter(cap, nap, d_sd, EnvCenter, true);*/ break;
  }
}

__device__ void changeBehavior(AgentProperties* cap, AgentProperties* nap, Agent3DProperties* d_a3pv, SimulationDetails * d_sd)
{
  if (cap->isLeader && cap->leaderType != ShapeSubLeader) {
    if (cap->agentIndex == 0) {
      chooseBestShapePosition(cap, nap, d_a3pv, d_sd);
    }
    if (checkNumberOfFollowers(cap, nap, d_sd, d_sd->lp[cap->leaderIndex].shapeAgents * 0.9, d_sd->lp[cap->leaderIndex].shapeAgents)) {
      d_sd->lp[cap->leaderIndex].stillAdopting = false;
      if (!changeLeaderState(cap, nap, d_a3pv, d_sd)) {
        performStateBehavior(cap, nap, d_a3pv, d_sd);
      }
      else {
        setStateProperties(cap, nap, d_sd);
        nap->previousState = cap->state;
      }

      d_sd->lp[cap->leaderIndex].state = nap->state;
      d_sd->lp[cap->leaderIndex].previousState = cap->state;
    }
    else {
      d_sd->lp[cap->leaderIndex].stillAdopting = true;  
      // if (d_sd->lp[cap->leaderIndex].shapePosition >= 0) {
      //  d_sd->shapePositionsChosen[d_sd->lp[cap->leaderIndex].shapePosition] = false;
      //  d_sd->lp[cap->leaderIndex].shapePosition = -1;
      // }
      nap->state = GatherFollowersState;
      setShapeFormingFollowers(cap, nap, d_a3pv, d_sd, true);
    }
  }
}
