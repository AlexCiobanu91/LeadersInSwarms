#pragma once

#include "Includes.h"

class Container
{
private:
  unsigned int _vbo;
  unsigned int _ibo;
  unsigned int _vao;
  unsigned int _numIndices;
  unsigned int _glProgramShader;
  int _swarmSize;
  int _agentIndex;

  glm::vec3 _centerPosition;

  glm::vec3 _minMaxY;
  glm::vec3 _modelSize;
  glm::vec3 _startPosition;
  glm::vec3 _speed;

  glm::vec3 _swarmCenter;
  glm::vec3 _moveSpeed;

  glm::mat4 _modelMatrix;
  std::vector<Agent3D*> _swarmReference;

public:

  float _minX, _maxX, _minZ, _maxZ;
  Container(unsigned int gl_program_shader)
  {
    _glProgramShader = gl_program_shader;
    _minX = 0;
    _maxX = 18000;

    _minZ = 0;
    _maxZ = 10000;
    create();
  }

  void setSwarmReference(std::vector<Agent3D*> & swarm)
  {
    _swarmReference = swarm;
  }

  unsigned int getVao()
  {
    return _vao;
  }

  void bind()
  {
    glBindVertexArray(_vao);
  }

  void render()
  {
    glUniformMatrix4fv(glGetUniformLocation(_glProgramShader, "model_matrix"), 1, false, glm::value_ptr(_modelMatrix));
    glDrawElements(GL_TRIANGLES, _numIndices, GL_UNSIGNED_INT, nullptr);
  }

  void create()
  {
    std::vector<VertexFormat>verts;
    std::vector<glm::uvec3>indx;

    ////////////////////// Up ////////////////////////
    verts.push_back(VertexFormat(_minX - 200, 0, _minZ - 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_minX - 200, 0, _minZ, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _minZ, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _minZ -200, 0, 0, 1, 1));

    indx.push_back(glm::uvec3(0, 1, 2));
    indx.push_back(glm::uvec3(2, 3, 0));

    ////////////////////// Down ////////////////////////
    verts.push_back(VertexFormat(_minX - 200, 0, _maxZ + 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_minX - 200, 0, _maxZ, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _maxZ, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _maxZ + 200, 0, 0, 1, 1));

    indx.push_back(glm::uvec3(4, 5, 6));
    indx.push_back(glm::uvec3(6, 7, 4));

    ////////////////////// Right ////////////////////////
    verts.push_back(VertexFormat(_maxX + 200, 0, _minZ - 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _minZ - 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX, 0, _maxZ + 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_maxX + 200, 0, _maxZ + 200, 0, 0, 1, 1));

    indx.push_back(glm::uvec3(8, 9, 10));
    indx.push_back(glm::uvec3(11, 8, 10));

    
    ////////////////////// Left ////////////////////////
    verts.push_back(VertexFormat(_minX - 200, 0, _minZ - 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_minX, 0, _minZ - 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_minX, 0, _maxZ + 200, 0, 0, 1, 1));
    verts.push_back(VertexFormat(_minX - 200, 0, _maxZ + 200, 0, 0, 1, 1));

    indx.push_back(glm::uvec3(12, 13, 14));
    indx.push_back(glm::uvec3(14, 15, 12));
    

    //vao
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);

    //vbo
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VertexFormat) * verts.size(), &verts[0], GL_STATIC_DRAW);

    //ibo
    glGenBuffers(1, &_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * indx.size() * 3, &indx[0], GL_STATIC_DRAW);

    int pipe = glGetAttribLocation(_glProgramShader, "in_position");
    glEnableVertexAttribArray(pipe);
    glVertexAttribPointer(pipe, 3, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), static_cast<void*>(nullptr));

    pipe = glGetAttribLocation(_glProgramShader, "in_color");
    glEnableVertexAttribArray(pipe);
    glVertexAttribPointer(pipe, 4, GL_FLOAT, GL_FALSE, sizeof(VertexFormat), reinterpret_cast<void*>(sizeof(glm::vec3)));
    _numIndices = (unsigned int)indx.size() * 3;
  }
};