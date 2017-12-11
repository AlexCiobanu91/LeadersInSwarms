#pragma once

//#include "VertexFormat.h"

#include "Includes.h"
#include "VertexFormat.h"
#include "SimulationDetails.h"
#include "ResearchDetails.h"
  //-------------------------------------------------------------------------------------------------
  // Informatii despre fereastra
struct WindowInfo {
  WindowInfo() {
    name = "nume default fereastra";
    width = 800; height = 600; start_position_x = start_position_y = 100;
    is_reshapable = true;
  }
  WindowInfo(std::string name, int width, int height, int start_position_x, int start_position_y, bool is_reshapable) {
    this->name = name;
    this->width = width;
    this->height = height;
    this->start_position_x = start_position_x;
    this->start_position_y = start_position_y;
    this->is_reshapable = is_reshapable;
  }
  void operator =(const WindowInfo& info) {
    name = info.name;
    width = info.width;
    height = info.height;
    start_position_x = info.start_position_x;
    start_position_y = info.start_position_y;
    is_reshapable = info.is_reshapable;
  }
  std::string name;													//numele ferestrei
  int width, height;													//inaltime, lungime
  int start_position_x, start_position_y;								//coordonate de start pt fereastra
  bool is_reshapable;													//e fereastra redimensionabila?
};

  //-------------------------------------------------------------------------------------------------
  // informatii despre framebuffer
struct FramebufferInfo {
  FramebufferInfo() {
    flags = GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH;
    msaa = false;
  }
  FramebufferInfo(bool color, bool depth, bool stencil, bool msaa) {
    flags = GLUT_DOUBLE;					//tot timpul folosim double buffering!
    if (color) flags |= GLUT_RGBA | GLUT_ALPHA;
    if (depth) flags |= GLUT_DEPTH;
    if (stencil) flags |= GLUT_STENCIL;
    if (msaa) flags |= GLUT_MULTISAMPLE;
    this->msaa = msaa;
  }
  void operator=(const FramebufferInfo& info) {
    flags = info.flags;
    msaa = info.msaa;
  }
  unsigned int flags;													// GL_RGBA | GL_DEPTH | GL_RGB | GL_STENCIL | ..
  bool msaa;															// MSAA 4x da/nu?
};

  //-------------------------------------------------------------------------------------------------
  //informatii despre contextul OpenGL
struct ContextInfo {
  ContextInfo() {
    major_version = 3;						//cel mai nou context e 4.4
    minor_version = 3;						//dar nu toate driverele sustin inca functionalitatea
    core = true;							//forteaza doar functiile core pentru contextul cerut.
  }
  ContextInfo(int major_version, int minor_version, bool core) {
    this->major_version = major_version;
    this->minor_version = minor_version;
    this->core = core;
  }
  void operator=(const ContextInfo &info) {
    major_version = info.major_version;
    minor_version = info.minor_version;
    core = info.core;
  }
  int major_version, minor_version;
  bool core;
};

