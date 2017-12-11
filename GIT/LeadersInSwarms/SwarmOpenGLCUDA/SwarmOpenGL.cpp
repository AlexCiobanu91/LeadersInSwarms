// SwarmOpenGL.cpp : Defines the entry point for the console application.
//

#include "Includes.h"
#include <random>
float moveRadius, moveStep;
float startX, startZ, startY;
float thresholdX, thresholdY, thresholdZ;
float speedX, speedY, speedZ;
float centerDistance;
int xpos, ypos, zpos, angle;
int lastx, lasty;
int windowId;
int noFrames;
float level;

float aspectRatio = 0.0f;
float horizontalAngle = 3.14f;
// vertical angle : 0, look at the horizon
float verticalAngle = 0.0f;
// Initial Field of View
float initialFoV = 45.0f;


float foV;
float speed = 9.0f; // 3 units / second
float mouseSpeed = 0.005f;
float zoomSpeed = 0.3f;
float mouseZoom = 0;
float maxMouseZoom = 0.7f;
float minMouseZoom = -0.7f;
float delay = 0;
float simulationTime = 0;

float leaderSpawnRate = 10;
float leaderLifeTime = 20;
float initialDelay = 20;
float leaderInfluence;

static bool bMouseMove = false;
static bool bStart = true;

bool dynamicObstacles;
bool allAgentsAvoid;
bool worldCamOn;
bool fullscreen;
std::vector<Agent3D*> swarm;

glm::vec3 worldCameraPos;
glm::vec3 worldCameraCenter;
glm::vec3 winCameraPos;
glm::vec3 winCameraCenter;
glm::vec3 right, up, direction, eyePosition;
glm::vec3 swarmDirection;

glm::mat4 projection_matrix;
glm::mat4 matModel, matView;

Camera *worldCamera;
Container *container;
unsigned int gl_program_shader;
unsigned int screen_width, screen_height;
GLuint vao, vbo, ibo;
GLuint ovao, ovbo, oibo;

bool* boolStariTaste;
bool* boolStariSpeciale;
bool represenationType;
bool createdLeaders;
bool dataSent;

WindowInfo _window_information;					//aici sunt tinute informatii despre fereastra
FramebufferInfo _framebuffer_information;		//aici sunt tinute informatii despre framebuffer
ContextInfo _context_information;				//aici sunt tinute informatii despre context

time_t startTime;
time_t lastSpawnTime;

std::string filename;

std::vector<std::string> outputFiles;

std::vector<VertexFormat> vertices, overtices;
std::vector<glm::uvec3> indexes, oindexes;

std::vector<int> agentsWithLeader;
std::vector<int> averageNumberOfAgentsPerLeader;
std::vector<int> averageNumberOfZonesPerLeader;
std::vector<int> zonesWithLeader;

Agent3DProperties* a3pv;
ObstacleProperties* opv;
SimulationDetails* sd;
PositionMatrix* pm;

extern "C" bool runMotivationLeader(int argc, const char **argv, std::string fis, Agent3DProperties* a3dpv, ObstacleProperties* opv, SimulationDetails* sd,
	bool dataSent, GLuint agentVbo, GLuint obstaclesVbo, GLuint positionMatrixVbo, bool dynamicObstacles, bool freeMemory = false);

glm::vec3 chooseLeaderColor(int leaderNumber) {
	switch (leaderNumber) {
	case 0:
		// red
		return glm::vec3(1, 0, 0);
	case 1:
		// green
		return glm::vec3(0, 1, 0);
	case 2:
		// blue
		return glm::vec3(0, 0, 1);
	case 3:
		// yellow
		return glm::vec3(1, 1, 0);
	case 4:
		// magenta
		return glm::vec3(1, 0, 1);
	case 5:
		// cyan
		return glm::vec3(0, 1, 1);
	case 6:
		// orange
		return glm::vec3(1, 0.5, 0);
	case 7:
		// dark green
		return glm::vec3(0, 0.2, 0);
	}
	return glm::vec3(0, 0, 0);
}

void drawText(const char *text, int length, int x, int y, glm::vec3 color, void* font) {
	glUseProgram(0);
	glColor3f(color.x, color.y, color.z);
	glDisable(GL_LIGHTING);
	GLint m_viewport[4];

	glGetIntegerv(GL_VIEWPORT, m_viewport);
	
	glMatrixMode(GL_PROJECTION); // change the current matrix to PROJECTION
	glPushMatrix(); // push current state of MODELVIEW matrix to stack
	glLoadIdentity(); // reset it again. (may not be required, but it my convention)
	gluOrtho2D(0, m_viewport[2], 0, m_viewport[3]); // orthographic perspective

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	glWindowPos2i(x, y);
	for (int i = 0; i<length; i++) {
		glutBitmapCharacter(font, (int)text[i]); // generation of characters in our text with 9 by 15 GLU font
	}

	glPopMatrix(); // get MODELVIEW matrix value from stack
	glMatrixMode(GL_PROJECTION); // change current matrix mode to MODELVIEW
	glPopMatrix(); // get MODELVIEW matrix value from stack
		
	glMatrixMode(GL_MODELVIEW); // change current matrix mode to PROJECTION
	glPopMatrix();

	glUseProgram(gl_program_shader);
}

void createCenterLeaders(time_t currentTime)
{
	/*
	std::vector<Agent3D*> swarmFormed = SwarmUtils::getSwarmFormed(swarmSize, swarm);
	int formedSwarmSize = swarmFormed.size();
	if (formedSwarmSize > noLeaders && formedSwarmSize > 2 * swarmSize / 4 && !createdLeaders)
	{
	createdLeaders = true;
	int leadersSoFar = 0;

	glm::vec2 swarmCenter = SwarmUtils::getSwarmCenter(swarmFormed);
	float distanceFromCenter = modelSize.x * 10;

	for (auto agent = swarmFormed.begin(); agent != swarmFormed.end(); agent++) {
	if (glm::distance((*agent)->getCenterPosition(), swarmCenter) < distanceFromCenter && !(*agent)->isLeader())
	{
	leadersSoFar++;
	swarm[(*agent)->getAgentIndex()]->setAsLeader(true);
	}

	if (leadersSoFar >= noLeaders)
	{
	break;
	}
	}
	}
	*/
}

void createBorderLeaders(time_t currentTime)
{
	/*
	std::vector<Agent3D*> swarmFormed = SwarmUtils::getSwarmFormed(swarmSize, swarm);
	int formedSwarmSize = swarmFormed.size();
	if (formedSwarmSize > noLeaders && formedSwarmSize > 2 * swarmSize / 4 && !createdLeaders)
	{
	createdLeaders = true;
	int leadersSoFar = 0;

	glm::vec2 swarmCenter = SwarmUtils::getSwarmCenter(swarmFormed);
	float distanceFromCenter = modelSize.x * 10;
	std::vector<Agent3D*> leadersSet;
	std::vector<Agent3D*> newLeader;
	for (auto agent = swarmFormed.begin(); agent != swarmFormed.end(); agent++) {
	if (glm::distance((*agent)->getCenterPosition(), swarmCenter) > distanceFromCenter
	&& !(*agent)->isLeader()
	&& (*agent)->getNoNeighbors() < 3)
	{
	if (leadersSet.size() == 0) {
	leadersSoFar++;
	swarm[(*agent)->getAgentIndex()]->setAsLeader(true);
	leadersSet.push_back((*agent));
	}
	else
	{
	bool farFromAll = true;
	for (auto leader = leadersSet.begin(); leader != leadersSet.end(); leader++) {
	if (glm::distance((*leader)->getCenterPosition(), (*agent)->getCenterPosition()) < modelSize.x * 5) {
	farFromAll = false;
	break;
	}
	}

	if (farFromAll) {
	leadersSoFar++;
	swarm[(*agent)->getAgentIndex()]->setAsLeader(true);
	leadersSet.push_back((*agent));
	}
	}
	}

	if (leadersSoFar >= noLeaders)
	{
	break;
	}
	}
	}
	*/
}

void createLeaders(time_t currentTime, int leaderPlacement)
{
	switch (leaderPlacement)
	{
	case 0:
		createCenterLeaders(currentTime);
		break;
	case 1:
		createBorderLeaders(currentTime);
		break;
	}
}

void CloseGLContext() {
	std::cout << "GLUT:\tTerminat" << std::endl;

	//	glutDestroyWindow(windowId);
	//glFlush();
	//glEnd();
	//glFinish();


	glutLeaveMainLoop();
}

void IdleGLContext()
{
	glutPostRedisplay();
}

void DoMovements()
{
	if (boolStariSpeciale[GLUT_KEY_RIGHT]) {
		eyePosition += right * speed;
		matView = glm::lookAt(eyePosition, eyePosition + direction, up);
	}
	if (boolStariSpeciale[GLUT_KEY_LEFT]) {
		eyePosition -= right * speed;
		matView = glm::lookAt(eyePosition, eyePosition + direction, up);
	}
	if (boolStariSpeciale[GLUT_KEY_UP]) {
		eyePosition += direction * speed;
		matView = glm::lookAt(eyePosition, eyePosition + direction, up);
	}
  if (boolStariSpeciale[GLUT_KEY_DOWN]) {
    eyePosition -= direction * speed;
    matView = glm::lookAt(eyePosition, eyePosition + direction, up);
  }

  if (boolStariSpeciale[GLUT_KEY_DELETE]) {
    eyePosition -= direction * speed;
    matView = glm::lookAt(eyePosition, eyePosition + direction, up);
  }
}

void InitMouseMovements()
{
	RECT actualDesktop;
	GetWindowRect(GetDesktopWindow(), &actualDesktop);

	//pentru miscarea camerei dupa mouse
	xpos = actualDesktop.right / 2;		ypos = actualDesktop.bottom / 2;
	lastx = actualDesktop.right / 2;	lasty = actualDesktop.bottom / 2;

	verticalAngle = 0.0f;
	horizontalAngle = 3.145f;

	direction = glm::vec3(cos(verticalAngle) * sin(horizontalAngle), sin(verticalAngle), cos(verticalAngle) * cos(horizontalAngle));
	right = glm::vec3(sin(horizontalAngle - 3.14f / 2.0f), 0.0f, cos(horizontalAngle - 3.14f / 2.0f));
	up = glm::cross(right, direction);

	foV = initialFoV;
}

void CreateCameras()
{
	eyePosition = glm::vec3(9000, 9550, 5010);
	matView = glm::lookAt(eyePosition, glm::vec3(9000, 0, 5000), glm::vec3(0, 1, -1));
}

LeaderType chooseLeaderType(int leaderType) {
  switch (leaderType) {
  case 1:
    return MotivationLeader;
  case 2:
    return IndependentLeader;
  case 3:
    return CenterMotivationLeader;
  case 4:
    return BorderMotivationLeader;
  case 5:
    return CenterIndependentLeader;
  case 6:
    return BorderIndependentLeader;
  case 7:
    return MixedLeader;
  case 8:
    return MixedLeaderCollisionEmerge;
  case 9:
    return AvoidanceEmergeLeader;
  case 10:
    return ShapeForming;
  case 11:
    return ShapeSubLeader;
  default:
    return MotivationLeader;
  }
}

SimulationType chooseSimulationType(int simulationType) {
  switch (simulationType) {
  case 0:
    return SimpleSimulation;
  case 1:
    return EnergySimulation;
  default:
    return SimpleSimulation;
  }
}

void InitSimulationDetails()
{
  sd = new SimulationDetails;
  sd->adoptionThreshold = AdoptionThreshold;
  sd->influenceTime = InfluenceTime;
  sd->leaderLifeSpan = LeaderLifeSpan;
  sd->leaderLifeTime = LeaderLifeTime;
  sd->leaderInfluence = LeaderInfluence;
  sd->maxSpeed = MaxSpeed;
  sd->obstacleSpeed = ObstacleSpeed;
  sd->influenceDistance = InfluenceDistance;
  sd->modelSize = ModelSize;
  sd->obstacleSize = ObstacleSize;
  sd->energyQuantity = InitialEnergy;
  sd->neighborDistance = NeighborDistance;
  sd->agentDistance = AgentDistance;
  sd->seed = Seed;
  sd->energyPercentPerFrame = EnergyPercentPerFrame;
  sd->influenceArea = InfluenceArea;
  sd->targetThreshold = TargetThreshold;
  sd->circleRadiusTarget = CircleRadiusTarget;

  sd->swarmSize = SwarmSize;
  sd->distanceThreshold = DistanceThreshold;
  sd->numberOfObstacles = Obstacles;
  sd->avoidanceType = AvoidanceAll;
  sd->noLeaders = Leaders;
  sd->currentLeaders = 0;
  sd->subLeaderLifeTime = SubLeaderLifeTime;

  sd->separationThreshold = SeparationThreshold;
  sd->movementFrames = MovementFrames;
  sd->position_radius = PositionRadius;
  sd->noFrames = 0;
  sd->collisions = 0;

  sd->shapeForming = false;
  sd->userControlled = false;
  sd->imposedShape = false;
  sd->dynamicObstacles = false;
  sd->fullscreen = true;

  // sd->influenceStartTimer = 0;
  sd->leaderLifeTimer = 0;
 

  sd->leaderType = MotivationLeader;
  sd->simulationType = SimpleSimulation;
  sd->moveShape = Square;
  sd->userDirection = UserNoDirection;
  
  sd->movementPercentages = MovementPercentages;
  sd->mapCoords = MapCoords;
  
  for (int i = 0; i < sd->numberOfObstacles; i++) {
    sd->agentsInObstacleArea[i] = 0;
  }

  for (int i = 0; i < 10000; i++) {
    sd->position_matrix[i] = 0;
    sd->target_matrix[i] = 0;
  }

  glm::vec2 shapeCenterInc = glm::vec2(sd->mapCoords.y - sd->mapCoords.x, sd->mapCoords.z - sd->mapCoords.w);
  shapeCenterInc /= static_cast<float>(sd->noLeaders);

  for (int i = 0; i < sd->noLeaders; i++) {
    sd->lp[i].swarmCenter = glm::vec2(0, 0);
    sd->lp[i].swarmSpeed = glm::vec2(0, 0);
    sd->lp[i].leaderPosition = glm::vec2(0, 0);
    sd->lp[i].leaderSpeed = glm::vec2(0, 0);
    sd->lp[i].leaderSubSpeed = glm::vec2(0, 0);
    sd->lp[i].movementRadius = glm::vec2(0, 0);

    sd->lp[i].heartbeat = 0;
    sd->lp[i].leaderDirection = 0;
    sd->lp[i].leaderMovementFrames = 0;
    sd->lp[i].followers = 0;
    sd->lp[i].energyMBorrow = 0;
    sd->lp[i].energyIBorrow = 0;
    sd->lp[i].framesMotivation = 1;
    sd->lp[i].framesIndependent = 1;
    sd->lp[i].leaderAgentIndex = -1;
    sd->lp[i].leaderFrames = 0;

    sd->lp[i].state = GatherFollowersState;
    sd->lp[i].previousState = GatherFollowersState;

    sd->lp[i].energyConsumedM = 0;
    sd->lp[i].energyConsumedI = 0;
    sd->lp[i].energyPerLeader = InitialEnergy;
    sd->lp[i].energyDebt = 0;
      
    sd->lp[i].stillAdopting = true;
    sd->lp[i].initialShape = true;

    sd->lp[i].circleCenterX = 0;
    sd->lp[i].circleCenterY = 0;
    sd->lp[i].circleRadius = 0;

    sd->lp[i].currentShape = Circle;
    sd->lp[i].targetShape = Circle;
    sd->lp[i].farAgents = 0;
    for (int j = 0; j < 100; j++) {
      sd->lp[i].shapeGroups[j] = -1;
    }

    sd->lp[i].allObstacleAgents = 0;
  }

  /*
  int centerPosition = (sd->position_radius / 2) * sd->position_radius + (sd->position_radius / 2);
  int radius = 13;
  for (int i = (sd->position_radius / 2) - radius; i <= (sd->position_radius / 2) + radius; i++) {
    for (int j = (sd->position_radius / 2) - radius; j <= (sd->position_radius / 2) + radius; j++) {
      sd->target_matrix[j * sd->position_radius + i] = 1;
    }
  }
  */
}

void initLeaderShape(int leaderNumber, int shape) {
  switch (shape) {
  case 0:
    sd->lp[leaderNumber].targetShape = Circle;
    break;
  case 1:
    sd->lp[leaderNumber].targetShape = Square;
    sd->lp[leaderNumber].numberOfShapeGroups = 4;
    sd->lp[leaderNumber].shapeGroups[0] = 0;
    sd->lp[leaderNumber].shapeGroups[1] = 3;
    sd->lp[leaderNumber].shapeGroups[2] = 12;
    sd->lp[leaderNumber].shapeGroups[3] = 15;
    break;
  case 2:
    sd->lp[leaderNumber].targetShape = Triangle;
    break;
  default:
    sd->lp[leaderNumber].targetShape = Circle;
    break;
  }
}

void InitSimulationDetails(int swarmSize, int noLeaders = 0, int noObstacles = 0, int leaderType = 0, int avoidanceType = 0,
  bool dynamicObstacles = 0, bool fullscreen = false, int simulationType = 0, bool shapeForming = false, 
  int shape1 = 0, int shape2 = 0, int shape3 = 0, int shape4 = 0, int shape5 = 0, int shape6 = 0, 
  int shape7 = 0, int shape8 = 0) {
  sd->swarmSize = swarmSize;
  sd->noLeaders = noLeaders;
  sd->numberOfObstacles = noObstacles;
  sd->leaderType = chooseLeaderType(leaderType);
  sd->dynamicObstacles = dynamicObstacles;
  sd->avoidanceType = avoidanceType;
  sd->fullscreen = fullscreen;
  sd->simulationType = chooseSimulationType(simulationType);
  sd->shapeForming = shapeForming;

  glm::vec2 shapeCenterInc = glm::vec2(sd->mapCoords.y - sd->mapCoords.x, sd->mapCoords.w - sd->mapCoords.z);
  if (sd->noLeaders > 3) {
    shapeCenterInc = glm::vec2(shapeCenterInc.x / static_cast<float>(4), shapeCenterInc.y / 3);
  }
  else if (sd->noLeaders > 1) {
    shapeCenterInc = glm::vec2(shapeCenterInc.x / static_cast<float>(sd->noLeaders + 1), shapeCenterInc.y / 3);
  }
  else {
    shapeCenterInc = glm::vec2(shapeCenterInc.x / static_cast<float>(sd->noLeaders + 1), shapeCenterInc.y / 2);
  }
  
  for (int i = 0; i < sd->noLeaders; i++) {
    sd->moveShape = Circle;
    sd->lp[i].targetShape = Circle;
    sd->imposedShape = true;

    sd->lp[i].shapeCenter = glm::vec2((shapeCenterInc.x - 500) * static_cast<float>( (i % 3) + 1) + 500 * static_cast<float>((i % 3) + 1), (shapeCenterInc.y - 1000)  + (shapeCenterInc.y + 1000) * ((int)(i / 3)));
    sd->lp[i].shapePosition = -1;
    sd->shapePositions[i] = sd->lp[i].shapeCenter;
    sd->shapePositionsChosen[i] = false;
    sd->lp[i].shapeAgents = sd->swarmSize / sd->noLeaders;
    sd->lp[i].subLeaders = 0;
    sd->lp[i].farthestAgent = -1;
    sd->lp[i].initialShape = true;
    sd->lp[i].hasSubLeaders = false;
    sd->lp[i].shapeForming = false;

    sd->lp[i].swarmLimitsX = glm::vec2(0, 0);
    sd->lp[i].swarmLimitsY = glm::vec2(0, 0);
  }
  initLeaderShape(0, shape1);
  initLeaderShape(1, shape2);
  initLeaderShape(2, shape3);
  initLeaderShape(3, shape4);
  initLeaderShape(4, shape5);
  initLeaderShape(5, shape6);
  initLeaderShape(6, shape7);
  initLeaderShape(7, shape8);

  switch (sd->noLeaders) {
  case 1:
  case 2:
    sd->circleRadiusTarget = CircleRadiusTarget;
    sd->subLeaderLifeTime = SubLeaderLifeTime;
    break;
  case 3:
    sd->circleRadiusTarget = CircleRadiusTarget3;
    sd->subLeaderLifeTime = SubLeaderLifeTime3;
    break;
  default:
    sd->circleRadiusTarget = CircleRadiusTarget3;
    sd->subLeaderLifeTime = SubLeaderLifeTime3;
    break;
  }
}

void InitObstacles()
{
	opv = new ObstacleProperties[sd->numberOfObstacles];

	for (auto i = 0; i < sd->numberOfObstacles; ++i)
	{
		speedX = (rand() % 2 == 0 ? -1.0f : 1.0f);
		if (represenationType) {
			speedY = (rand() % 2 == 0 ? -1.0f : 1.0f);
		}
		else
		{
			speedY = 0;
		}
		speedZ = (rand() % 2 == 0 ? -1.0f : 1.0f);


		auto centerX = 12900 - (rand() % 18000);
		auto centerY = 0;
		if (represenationType) {
			centerY = 1900 - rand() % 1900;
		}
		auto centerZ = 5000 - (rand() % 9900);

		auto agentSpeed = glm::vec2(speedX, speedZ);
		auto modelCenterPosition = glm::vec2(centerX, centerZ);

		Obstacle * obstacle = new Obstacle(i, (int) sd->obstacleSize, modelCenterPosition, agentSpeed, &overtices, &oindexes);
		opv[i] = obstacle->getProperties();
	}

	//vao
	glGenVertexArrays(1, &ovao);
	glBindVertexArray(ovao);

	//vbo
	glGenBuffers(1, &ovbo);
	glBindBuffer(GL_ARRAY_BUFFER, ovbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(VertexFormat) * overtices.size(), &overtices[0], GL_STATIC_DRAW);

	//ibo
	glGenBuffers(1, &oibo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, oibo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * oindexes.size() * 3, &oindexes[0], GL_STATIC_DRAW);

	int pipe = glGetAttribLocation(gl_program_shader, "in_position");
	glEnableVertexAttribArray(pipe);
	glVertexAttribPointer(pipe, 3, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), static_cast<void*>(nullptr));

	pipe = glGetAttribLocation(gl_program_shader, "in_color");
	glEnableVertexAttribArray(pipe);
	glVertexAttribPointer(pipe, 4, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), reinterpret_cast<void*>(sizeof(glm::vec2)));
}

void InitPositionMatrix() {
  pm = new PositionMatrix(gl_program_shader, glm::vec2(sd->position_radius, sd->position_radius), sd->modelSize);
}

void InitSwarm()
{
	swarm.clear();
	averageNumberOfAgentsPerLeader.clear();
	averageNumberOfZonesPerLeader.clear();
	agentsWithLeader.clear();
	zonesWithLeader.clear();

	a3pv = new Agent3DProperties[sd->swarmSize];
  vertices = std::vector<VertexFormat>(4 * sd->swarmSize);
  indexes = std::vector<glm::uvec3>(5 * sd->swarmSize);

	// Random seed
	std::random_device rd;

	// Initialize Mersenne Twister pseudo-random number generator
	std::mt19937 gen(rd());

	// Generate pseudo-random numbers
	// uniformly distributed in range (1, 100)
	//std::uniform_int_distribution<> disX(0, 17900);
	//std::uniform_int_distribution<> disY(0, 1900);
	//std::uniform_int_distribution<> disZ(0, 9900);
	//std::uniform_int_distribution<> disS(0, 200);
  
  /*
  for (int j = 0; j < sd->swarmSize; j++)
  {
    speedX = (-100 + disS(gen)) / 100.0f;
    if (represenationType) {
      speedY = (rand() % 2 == 0 ? -1.0f : 1.0f);
    }
    else
    {
      speedY = 0;
    }

    speedZ = (-100 + disS(gen)) / 100.0f;

    auto centerX = disX(gen);
    auto centerY = 0;
    if (represenationType) {
      centerY = 1900 - rand() % 1900;
    }
    auto centerZ = disZ(gen);

    //std::cout << "center " << centerX << " " << centerZ << std::endl;

    // auto agentSpeed = glm::vec2(0., 0., 0.);
    auto agentSpeed = glm::vec2(speedX, speedZ);
    auto modelCenterPosition = glm::vec2(centerX, centerZ);
    Agent3D * agent = new Agent3D(modelCenterPosition, sd->modelSize, agentSpeed, j, vertices, indexes);
    a3pv[j] = agent->getProperties();
  }
  */
  
  std::uniform_int_distribution<> disZ(4000, 5000);

  for (int i = 0; i < sd->noLeaders; i++) {
      std::uniform_int_distribution<> disX(8500, 8600);
      std::uniform_int_distribution<> disZ(4500, 4600);
      if (sd->noLeaders > 1) {
        if (i > 2) {
          disX = std::uniform_int_distribution<>(3500 + 4500 * (i - 3), 3600 + 4500 * (i - 3));
          disZ = std::uniform_int_distribution<>(6500, 6600);
        }
        else {
          disX = std::uniform_int_distribution<>(3500 + 5000 * i, 3600 + 5000 * i);
          disZ = std::uniform_int_distribution<>(2500, 2600);
        }
      }
    
    
    std::uniform_int_distribution<> disS(0, 200);

    speedX = (-100 + disS(gen)) / 100.0f;
    speedZ = (-100 + disS(gen)) / 100.0f;

    auto centerX = disX(gen);
    auto centerY = 0;
    if (represenationType) {
      centerY = 1900 - rand() % 1900;
    }
    auto centerZ = disZ(gen);

    auto agentSpeed = glm::vec2(speedX, speedZ);
    auto modelCenterPosition = glm::vec2(centerX, centerZ);
    Agent3D * agent = new Agent3D(modelCenterPosition, sd->modelSize, agentSpeed, i, vertices, indexes);
    a3pv[i] = agent->getProperties();
  }
  int agentsPerLeader = (sd->swarmSize / sd->noLeaders);
  for (int i = 0; i < sd->noLeaders; i++) {
    
    std::uniform_int_distribution<> disX(8000, 9000);
    std::uniform_int_distribution<> disZ(4000, 5000);
    if (sd->noLeaders > 1) {
      if (i > 2) {
        disX = std::uniform_int_distribution<>(3000 + 4500 * (i - 3), 5000 + 4500 * (i - 3));
        disZ = std::uniform_int_distribution<>(6000, 7000);
      }
      else {
        disX = std::uniform_int_distribution<>(3000 + 5000 * i, 5000 + 5000 * i);
        disZ = std::uniform_int_distribution<>(2000, 3000);
      }
    }


    std::uniform_int_distribution<> disS(0, 200);

    for (int j = glm::max(sd->noLeaders, agentsPerLeader * i); j < glm::min(agentsPerLeader * (i + 1), sd->swarmSize); j++)
    {
      speedX = (-100 + disS(gen)) / 100.0f;
      if (represenationType) {
        speedY = (rand() % 2 == 0 ? -1.0f : 1.0f);
      }
      else
      {
        speedY = 0;
      }

      speedZ = (-100 + disS(gen)) / 100.0f;

      auto centerX = disX(gen);
      auto centerY = 0;
      if (represenationType) {
        centerY = 1900 - rand() % 1900;
      }
      auto centerZ = disZ(gen);

      //std::cout << "center " << centerX << " " << centerZ << std::endl;

      // auto agentSpeed = glm::vec2(0., 0., 0.);
      auto agentSpeed = glm::vec2(speedX, speedZ);
      auto modelCenterPosition = glm::vec2(centerX, centerZ);
      Agent3D * agent = new Agent3D(modelCenterPosition, sd->modelSize, agentSpeed, j, vertices, indexes);
      a3pv[j] = agent->getProperties();
    }
  }
  
	//vao
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	//vbo
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(VertexFormat) * vertices.size(), &vertices[0], GL_STATIC_DRAW);

	//ibo
	glGenBuffers(1, &ibo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * indexes.size() * 3, &indexes[0], GL_STATIC_DRAW);

	int pipe = glGetAttribLocation(gl_program_shader, "in_position");
	glEnableVertexAttribArray(pipe);
	glVertexAttribPointer(pipe, 3, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), static_cast<void*>(nullptr));

	pipe = glGetAttribLocation(gl_program_shader, "in_color");
	glEnableVertexAttribArray(pipe);
	glVertexAttribPointer(pipe, 4, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), reinterpret_cast<void*>(sizeof(glm::vec3)));


	for (int i = 0; i < sd->noLeaders + 2; i++)
	{
		averageNumberOfAgentsPerLeader.push_back(0);
		averageNumberOfZonesPerLeader.push_back(0);
	}
}

void InitShaders()
{
	gl_program_shader = loadShader("Shaders\\shader_vertex.glsl", "Shaders\\shader_fragment.glsl");
}

void InitKeyboard()
{
	boolStariTaste = new bool[256];
	boolStariSpeciale = new bool[256];

	for (int i = 0; i < 255; i++) {
		boolStariSpeciale[i] = false;
		boolStariTaste[i] = false;
	}
}

void CreateEnvironment()
{
	container = new Container(gl_program_shader);
	container->setSwarmReference(swarm);
}

void Init(int swarmSize = 1000, int noLeaders = 0, int noObstacles = 0, int leaderType = 0, int avoidanceType = 0,
  bool dynamicObstacles = 0, bool fullscreen = false, int simulationType = 0, bool shapeForming = false, 
  int shape1 = 0, int shape2 = 0, int shape3 = 0, int shape4 = 0, int shape5 = 0, int shape6 = 0, int shape7 = 0, 
  int shape8 = 0) {
  srand((unsigned int)time(NULL));

  glClearColor(0.5, 0.5, 0.5, 1);
  glClearDepth(1);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  InitKeyboard();
  InitShaders();
  InitSimulationDetails();
  InitSimulationDetails(swarmSize, noLeaders, noObstacles, leaderType, avoidanceType, dynamicObstacles, fullscreen, simulationType, shapeForming, shape1, shape2, shape3, shape4, shape5, shape6, shape7, shape8);
  CreateEnvironment();

  InitMouseMovements();

  InitObstacles();
  InitSwarm();
  InitPositionMatrix();
  CreateCameras();

  noFrames = 0;
  createdLeaders = false;
  dataSent = false;
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  // glEnable(GL_CULL_FACE);
  if (fullscreen) {
    glutFullScreenToggle();
  }
}

void Unload() {
	//distruge shader
	glDeleteProgram(gl_program_shader);
}

void RenderEnvironment()
{
	container->bind();
	container->render();
  //pm->bind();
  //pm->render();
}

void SetViewProjectionMatrix()
{
	projection_matrix = glm::perspective(foV, aspectRatio, 0.1f, 10000.0f);
	glUniformMatrix4fv(glGetUniformLocation(gl_program_shader, "view_matrix"), 1, false, glm::value_ptr(matView));
	glUniformMatrix4fv(glGetUniformLocation(gl_program_shader, "projection_matrix"), 1, false, glm::value_ptr(projection_matrix));
	glUniformMatrix4fv(glGetUniformLocation(gl_program_shader, "model_matrix"), 1, false, glm::value_ptr(matModel));
}

void NotifyBeginFrame()
{
	noFrames++;
}

void NotifyEndFrame()
{
	//if (noFrames >= NoFrames) {
	//	CloseGLContext();
	//}
}

void cudaTest(int argc, char ** argv)
{
	runMotivationLeader(argc, (const char **)argv, filename, a3pv, opv, sd, dataSent, vbo, ovbo, pm->getVbo(), dynamicObstacles);
	sd->noFrames++;
	dataSent = true;
}

void DrawDetails()
{
	GLint m_viewport[4];

	glGetIntegerv(GL_VIEWPORT, m_viewport);

	time_t currentTime;
	time(&currentTime);
	float timePassed = (float)difftime(currentTime, startTime);

  std::string text = "Leaders in Swarms - Alexandru-Catalin Ciobanu";
  drawText(text.data(), (int)text.size(), 48, m_viewport[3] - 52, glm::vec3(0, 0, 1), GLUT_BITMAP_HELVETICA_18);
  /*
	text = "Frames passed: " + std::to_string(noFrames);
	drawText(text.data(), (int)text.size(), 48, m_viewport[3] - 70, glm::vec3(0, 0, 0), GLUT_BITMAP_HELVETICA_18);

	text = "Time passed " + std::to_string(static_cast<int>(timePassed)) + " s";
	drawText(text.data(), (int)text.size(), 48, m_viewport[3] - 88, glm::vec3(0, 0, 0), GLUT_BITMAP_HELVETICA_18);

	text = "Center (" + std::to_string((MapCoords.y + MapCoords.x) / 2) + ",0," + std::to_string((MapCoords.w + MapCoords.z) / 2) + ")";
	drawText(text.data(), (int)text.size(), 48, m_viewport[3] - 106, glm::vec3(0, 0, 0), GLUT_BITMAP_HELVETICA_18);

  int bitmapLeaderTitle = 18;
  int bitmapSize = 12;
  int startPosition = 106;
  int initialPos = m_viewport[3] - startPosition;
  int pos = m_viewport[3] - startPosition;
  for (int i = 0; i < sd->noLeaders; i++) {

    int h_pos = 48;
    if (i > 3) {
      h_pos = m_viewport[2] - 250;
      if (i == 4) {
        pos = initialPos;
      }
    }
    //" Cons: " + std::to_string(energyConsumedM) + "/" + std::to_string(energyConsumedI) +
    //" energy: " + std::to_string(static_cast<int>(sd->energyPerLeader[i])) +
    //" debt: " + std::to_string(static_cast<int>(sd->energyDebt[i])) +
    //" Borrow(100): " + std::to_string(sd->energyMBorrow[i]) + "/" + std::to_string(sd->energyIBorrow[i]) +

    float energyConsumedM = sd->lp[i].energyConsumedM / static_cast<float>(sd->lp[i].framesMotivation);
    float energyConsumedI = sd->lp[i].energyConsumedI / static_cast<float>(sd->lp[i].framesIndependent);
   
    text = "Leader " + std::to_string(i + 1);
    pos -= bitmapLeaderTitle;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_18);

    text = "Followers: " + std::to_string(sd->lp[i].followers);
    pos -= bitmapLeaderTitle;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "State: " + std::to_string(sd->lp[i].state) + " PrevState: " + std::to_string(sd->lp[i].previousState);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "LeaderCenter: (" + std::to_string((int)sd->lp[i].leaderPosition.x) + "," + std::to_string((int)sd->lp[i].leaderPosition.y) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "SwarmCenter: (" + std::to_string((int)sd->lp[i].swarmCenter.x) + "," + std::to_string((int)sd->lp[i].swarmCenter.y) + ")"
      + " Diff (" + std::to_string((int)glm::distance(sd->lp[i].swarmCenter, sd->lp[i].leaderPosition)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
    

    text = "Circle: (" + std::to_string((int)(sd->lp[i].circleCenterX)) + "," + std::to_string((int)(sd->lp[i].circleCenterY)) + "," + std::to_string((int)(sd->lp[i].circleRadius)) + ")"
      + " Diff (" + std::to_string((int)glm::distance(glm::vec2(sd->lp[i].circleCenterX, sd->lp[i].circleCenterY), sd->lp[i].leaderPosition)) + "," + 
                    std::to_string((int)(sd->lp[i].circleRadius - sd->circleRadiusTarget)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "LeaderSpeed: (" + std::to_string((int)(sd->lp[i].leaderSpeed.x * 10)) + "," + std::to_string((int)(sd->lp[i].leaderSpeed.y * 10)) + ")"
          + " SwarmSpeed: (" + std::to_string((int)(sd->lp[i].swarmSpeed.x * 10)) + "," + std::to_string((int)(sd->lp[i].swarmSpeed.y * 10)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);


    text = "Leader Shape: " + std::to_string(sd->lp[i].currentShape) + " Target Shape: " + std::to_string(sd->lp[i].targetShape);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
    
    text = "Initial Shape: " + std::to_string(sd->lp[i].initialShape);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "Leader Direction: " + std::to_string(sd->lp[i].leaderDirection);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    // text = "Leader Movement Frames " + std::to_string(sd->lp[i].leaderMovementFrames);
    // pos -= bitmapSize;
    // drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i + 1), GLUT_BITMAP_HELVETICA_12);

    text = "Swarm (" + std::to_string((int)sd->lp[i].swarmLimitsX.x) + "," +
                       std::to_string((int)sd->lp[i].swarmLimitsX.y) + "," +
                       std::to_string((int)sd->lp[i].swarmLimitsY.x) + "," +
                       std::to_string((int)sd->lp[i].swarmLimitsY.y) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);


    float heightWidthDiff = glm::distance(glm::distance(sd->lp[i].swarmLimitsX.x, sd->lp[i].swarmLimitsX.y),
                                          glm::distance(sd->lp[i].swarmLimitsY.x, sd->lp[i].swarmLimitsY.y));
    text = "Swarm Diff (" + std::to_string((int)heightWidthDiff) + ",";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "Movement radius (" + std::to_string((int)(sd->lp[i].movementRadius.x * 10)) + ", " + std::to_string((int)(sd->lp[i].movementRadius.y * 10)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    // text = "User controlled: " + std::to_string(sd->userControlled) + " Direction: " + std::to_string(sd->userDirection);
    // pos -= bitmapSize;
    // drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i + 1), GLUT_BITMAP_HELVETICA_12);

    // text = "Imposed shape : " + std::to_string(sd->moveShape) + " Value: " + std::to_string(sd->imposedShape);
    // pos -= bitmapSize;
    // drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i + 1), GLUT_BITMAP_HELVETICA_12);

    text = "SubLeaders : " + std::to_string(sd->lp[i].subLeaders);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "farthestAgent : " + std::to_string(sd->lp[i].farthestAgent);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
   
    text = "Far Agents : " + std::to_string(sd->lp[i].farAgents);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
    
    text = "heartbeat : " + std::to_string(sd->lp[i].heartbeat);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "leaderFrames : " + std::to_string(sd->lp[i].leaderFrames);
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "SubLeaderSpeed: (" + std::to_string((int)(sd->lp[i].leaderSubSpeed.x * 10)) + "," + std::to_string((int)(sd->lp[i].leaderSubSpeed.y * 10)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
 
    text = "FarthestAgentPosition: (" + std::to_string((int)(sd->lp[i].farthestAgentPosition.x)) + "," + std::to_string((int)(sd->lp[i].farthestAgentPosition.y)) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
    
    text = "DistanceToLeader: (" + std::to_string((int)(glm::distance(sd->lp[i].farthestAgentPosition, sd->lp[i].leaderPosition))) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "ShapeAgents: (" + std::to_string(sd->lp[i].shapeAgents) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);

    text = "StillAdopting: (" + std::to_string(sd->lp[i].stillAdopting) + ")";
    pos -= bitmapSize;
    drawText(text.data(), (int)text.size(), h_pos, pos, chooseLeaderColor(i), GLUT_BITMAP_HELVETICA_12);
  }
  */
}


void NotifyDisplayFrame()
{
	NotifyBeginFrame();

	//pe tot ecranul
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	SetViewProjectionMatrix();

	glUseProgram(gl_program_shader);
	RenderEnvironment();
	cudaTest(0, NULL);

	glBindVertexArray(vao);
	glDrawElements(GL_TRIANGLES, (GLsizei)indexes.size() * 3, GL_UNSIGNED_INT, nullptr);

	glBindVertexArray(ovao);
	glDrawElements(GL_TRIANGLES, (GLsizei)oindexes.size() * 3, GL_UNSIGNED_INT, nullptr);

	DrawDetails();

	glFlush();
	glutSwapBuffers();

	NotifyEndFrame();
}

//functie care e chemata cand se schimba dimensiunea ferestrei initiale
void NotifyReshape(int width, int height)
{
	//reshape
	if (height == 0) height = 1;
	screen_width = width;
	screen_height = height;
	aspectRatio = (float)width / (float)height;
	glViewport(0, 0, screen_width, screen_height);
	projection_matrix = glm::perspective(foV, aspectRatio, 0.1f, 10000.0f);

	_window_information.width = width;
	_window_information.height = height;
}

//tasta apasata
void NotifyKeyPressed(unsigned char key_pressed, int mouse_x, int mouse_y)
{
	if (key_pressed == 27) {
		CloseGLContext();
	}

	if (key_pressed == 'w') {
		static bool wire = true;
		wire = !wire;
		glPolygonMode(GL_FRONT_AND_BACK, (wire ? GL_LINE : GL_FILL));
	}

	if (key_pressed == 'q') {
		bMouseMove = !bMouseMove;
	}

	if (key_pressed == 's') {
		bStart = !bStart;
	}

  if (key_pressed == 'l') {
    sd->userDirection = UserLEFT;
  }

  if (key_pressed == 'j') {
    sd->userDirection = UserRIGHT;
  }

  if (key_pressed == 'i') {
    sd->userDirection = UserUP;
  }

  if (key_pressed == 'k') {
    sd->userDirection = UserDOWN;
  }

  if (key_pressed == 'o') {
    sd->userDirection = UserNoDirection;
    sd->userControlled = !sd->userControlled;
  }

  if (key_pressed == 'c') {
	  sd->moveShape = Circle;
	  sd->userControlled = false;
	  sd->imposedShape = true;
  }

  if (key_pressed == 'p') {
	  sd->moveShape = Square;
	  sd->userControlled = false;
	  sd->imposedShape = true;
  }

}

//tasta ridicata
void NotifyKeyReleased(unsigned char key_released, int mouse_x, int mouse_y)
{	}

//tasta speciala (up/down/F1/F2..) apasata
void NotifySpecialKeyPressed(int key_pressed, int mouse_x, int mouse_y)
{
	switch (key_pressed) {
	case GLUT_KEY_RIGHT:
		boolStariSpeciale[GLUT_KEY_RIGHT] = true;
		break;
	case GLUT_KEY_LEFT:
		boolStariSpeciale[GLUT_KEY_LEFT] = true;
		break;
	case GLUT_KEY_DOWN:
		boolStariSpeciale[GLUT_KEY_DOWN] = true;
		break;
	case GLUT_KEY_UP:
		boolStariSpeciale[GLUT_KEY_UP] = true;
		break;
	}

	if (key_pressed == GLUT_KEY_F1) glutFullScreenToggle();

}

//tasta speciala ridicata
void NotifySpecialKeyReleased(int key_released, int mouse_x, int mouse_y)
{
	switch (key_released) {
	case GLUT_KEY_RIGHT:
		boolStariSpeciale[GLUT_KEY_RIGHT] = false;
		break;
	case GLUT_KEY_LEFT:
		boolStariSpeciale[GLUT_KEY_LEFT] = false;
		break;
	case GLUT_KEY_DOWN:
		boolStariSpeciale[GLUT_KEY_DOWN] = false;
		break;
	case GLUT_KEY_UP:
		boolStariSpeciale[GLUT_KEY_UP] = false;
		break;
	}
}

//drag cu mouse-ul
void NotifyMouseDrag(int mouse_x, int mouse_y)
{ }

//am miscat mouseul (fara sa apas vreun buton)
void NotifyMouseMove(int mouse_x, int mouse_y)
{
	RECT actualDesktop;
	GetWindowRect(GetDesktopWindow(), &actualDesktop);

	if (bMouseMove) {
		xpos = mouse_x;
		ypos = mouse_y;

		if (xpos != lastx || ypos != lasty) {
			horizontalAngle += mouseSpeed * float(actualDesktop.right / 2 - xpos);
			verticalAngle += mouseSpeed * float(actualDesktop.bottom / 2 - ypos);

			direction = glm::vec3(cos(verticalAngle) * sin(horizontalAngle), sin(verticalAngle), cos(verticalAngle) * cos(horizontalAngle));
			right = glm::vec3(sin(horizontalAngle - 3.14f / 2.0f), 0.0f, cos(horizontalAngle - 3.14f / 2.0f));
			up = glm::cross(right, direction);

			matView = glm::lookAt(eyePosition, eyePosition + direction, up);
			glutWarpPointer(actualDesktop.right / 2, actualDesktop.bottom / 2);

			lastx = mouse_x;
			lasty = mouse_y;
		}
	}
}

//am apasat pe un boton
void NotifyMouseClick(int button, int state, int mouse_x, int mouse_y)
{ }

//scroll cu mouse-ul
void NotifyMouseScroll(int wheel, int direction, int mouse_x, int mouse_y)
{
	/* if (direction > 0 && mouseZoom < maxMouseZoom)
	{
	foV -= zoomSpeed;
	mouseZoom -= zoomSpeed;
	}
	if (direction < 0 && mouseZoom > minMouseZoom)
	{
	foV += zoomSpeed;
	mouseZoom += zoomSpeed;
	}*/

}

void InitGLContext(const WindowInfo &window, const ContextInfo &context, const FramebufferInfo &framebuffer)
{
	//copiaza informatie pentru fereastra,context,framebuffer
	_context_information = context;
	_window_information = window;
	_framebuffer_information = framebuffer;

	//cerem glut un context OpenGL
	glutInitContextVersion(context.major_version, context.minor_version);
	glutInitContextFlags(GLUT_DEBUG);
	if (context.core) glutInitContextProfile(GLUT_CORE_PROFILE);
	else glutInitContextProfile(GLUT_COMPATIBILITY_PROFILE);

	//argumente fake pentru ca nu folosim glut in linie de comanda
	int fakeargc = 1;		char *fakeargv[] = { "fake",NULL };
	glutInit(&fakeargc, fakeargv);
	glutInitDisplayMode(framebuffer.flags);
	glutInitWindowPosition(window.start_position_x, window.start_position_y);
	glutInitWindowSize(window.width, window.height);
	windowId = glutCreateWindow(window.name.c_str());

	//leaga functiile locale la GLUT
	glutIdleFunc(IdleGLContext);
	glutCloseFunc(CloseGLContext);
	glutDisplayFunc(NotifyDisplayFrame);
	glutReshapeFunc(NotifyReshape);
	glutKeyboardFunc(NotifyKeyPressed);
	glutKeyboardUpFunc(NotifyKeyReleased);
	glutSpecialFunc(NotifySpecialKeyPressed);
	glutSpecialUpFunc(NotifySpecialKeyReleased);
	glutMotionFunc(NotifyMouseDrag);
	glutPassiveMotionFunc(NotifyMouseMove);
	glutMouseFunc(NotifyMouseClick);
	glutMouseWheelFunc(NotifyMouseScroll);

	//scrie la consola diverse detalii utile
	const unsigned char* renderer = glGetString(GL_RENDERER);
	const unsigned char* vendor = glGetString(GL_VENDOR);
	const unsigned char* version = glGetString(GL_VERSION);
	std::cout << "*******************************************************************************" << std::endl;
	std::cout << "GLUT:initializare" << std::endl;
	std::cout << "GLUT:\tVendor : " << vendor << std::endl;
	std::cout << "GLUT:\tRenderer : " << renderer << std::endl;
	std::cout << "GLUT:\tutilizez versiunea de OpenGl : " << version << std::endl;
	std::cout << "GLUT:\tFereasta initiala se numeste `" << window.name << "`, are dimensiunile  (" << window.width << "X" << window.height;
	std::cout << ") incepe de la coordonatele de ecran (" << window.start_position_x << "X" << window.start_position_y;
	std::cout << ") si " << ((window.is_reshapable) ? "este" : "nu este") << " redimensionabila" << std::endl;
	std::cout << "GLUT:\tFramebuffer initial contine buffere(duble) pentru" << std::endl;
	if (glutGet(GLUT_WINDOW_RGBA)) {
		int r_bits, g_bits, b_bits, a_bits;
		glGetIntegerv(GL_RED_BITS, &r_bits);	glGetIntegerv(GL_GREEN_BITS, &g_bits);
		glGetIntegerv(GL_BLUE_BITS, &b_bits);	glGetIntegerv(GL_ALPHA_BITS, &a_bits);
		std::cout << "\tCuloare R" << r_bits << "G" << g_bits << "B" << b_bits << "A" << a_bits << std::endl;
	}
	if (_framebuffer_information.flags&GLUT_DEPTH) {
		int d_bits;	glGetIntegerv(GL_DEPTH_BITS, &d_bits);
		std::cout << "\tAdancime DEPTH" << d_bits << std::endl;
	}
	if (_framebuffer_information.flags&GLUT_STENCIL) {
		int s_bits;	glGetIntegerv(GL_STENCIL_BITS, &s_bits);
		std::cout << "\tStencil STENCIL" << s_bits << std::endl;
	}
	if (_framebuffer_information.flags&GLUT_MULTISAMPLE) std::cout << "\tmultisampling cu 4 sample-uri per pixel" << std::endl;
	std::cout << "GLUT:\tContextul OpenGL este " << _context_information.major_version << "." << _context_information.minor_version;
	std::cout << " si profilul este de " << ((_context_information.core) ? "core" : "compatibilitate") << std::endl;
	std::cout << "*******************************************************************************" << std::endl;

	//cand glut este inchis este returnat la main pentru oportunitatea de cleanup corect
	glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_GLUTMAINLOOP_RETURNS);

}

void Load(int swarmSize = 1000, int noLeaders = 0, int noObstacles = 0, int leaderType = 0, int avoidanceType = 0, 
			bool dynamicObstacles = 0, bool fullscreen = false, int simulationType = 0, bool shapeForming = false, 
      int shape1 = 0, int shape2 = 0, int shape3 = 0, int shape4 = 0, int shape5 = 0, int shape6 = 0, 
      int shape7 = 0, int shape8 = 0 ) {
	//initializeaza GLUT (fereastra + input + context OpenGL)
	WindowInfo window(std::string("lab shadere 3 - camera"), 800, 600, 100, 100, true);
	ContextInfo context(3, 1, false);
	FramebufferInfo framebuffer(true, true, true, true);
	InitGLContext(window, context, framebuffer);

	// ignora tastele ce sunt tinute apasate
	glutIgnoreKeyRepeat(0);

	//initializeaza GLEW (ne incarca functiile openGL, altfel ar trebui sa facem asta manual!)
	glewExperimental = true;
	glewInit();
	std::cout << "GLEW:initializare" << std::endl;

	time(&startTime);
	//initializare
    std::cout << "before init" << std::endl;
	Init(swarmSize, noLeaders, noObstacles, leaderType, avoidanceType, dynamicObstacles, fullscreen, simulationType, shapeForming, shape1, shape2, shape3, shape4, shape5, shape6, shape7, shape8);

	//run
    
    glutMainLoop();
    
	glDeleteBuffers(1, &vao);
	glDeleteBuffers(1, &vbo);
	glDeleteBuffers(1, &ibo);

	glDeleteBuffers(1, &ovao);
	glDeleteBuffers(1, &ovbo);
	glDeleteBuffers(1, &oibo);

	runMotivationLeader(0, NULL, filename, NULL, NULL, sd, true, NULL, NULL, NULL, false, true);
}

int main(int argc, char** argv)
{
  int swarmSize = atoi(argv[1]);
  int noLeaders = atoi(argv[2]);
  int obstacles = atoi(argv[3]);
  int leaderType = atoi(argv[4]);
  int avoidanceType = atoi(argv[5]);
  bool dynamicObstacles = atoi(argv[6]) == 0 ? false : true;
  bool fullscreen = atoi(argv[7]) == 0 ? false : true;
  int simulationType = atoi(argv[8]);
  bool shapeForming = atoi(argv[9]) == 0 ? false : true;
  int shape1 = atoi(argv[10]);
  int shape2 = atoi(argv[11]);
  int shape3 = atoi(argv[12]);
  int shape4 = atoi(argv[13]);
  int shape5 = atoi(argv[14]);
  int shape6 = atoi(argv[15]);
  int shape7 = atoi(argv[16]);
  int shape8 = atoi(argv[17]);


  std::string filename = argv[18];

  //std::cout << filename << std::endl;

  Load(swarmSize, noLeaders, obstacles, leaderType, avoidanceType, dynamicObstacles, fullscreen, simulationType, shapeForming, shape1, shape2, shape3, shape4, shape5, shape6, shape7, shape8);

  return 0;
}

