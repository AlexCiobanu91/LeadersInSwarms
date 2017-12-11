// standard includes
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <vector>
#include <iostream>
#include <fstream>

// OpenGL runtime
#include "GL\glew.h"
#include "GL\freeglut.h"
#include "glm\gtc\matrix_transform.hpp"
#include "glm\gtc\type_ptr.hpp"
#include "glm\glm.hpp"
#include "GLFW\glfw3.h"

#include "..\SwarmOpenGLCUDA\Agent3DProperties.h"
#include "..\SwarmOpenGLCUDA\VertexFormat.h"
#include "..\SwarmOpenGLCUDA\SimulationDetails.h"
#include "..\SwarmOpenGLCUDA\ObstacleProperties.h"
#include "..\SwarmOpenGLCUDA\Definitions.h"
#include "..\SwarmOpenGLCUDA\ResearchDetails.h"
#include "..\SwarmOpenGLCUDA\PositionMatrix.h"

// CUDA runtime
#include <cuda_runtime.h>
#include <curand.h>
#include <curand_kernel.h>
#include <cuda_gl_interop.h>
#include <vector_types.h>
#include <driver_types.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>