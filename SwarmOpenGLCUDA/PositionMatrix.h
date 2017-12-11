#pragma once

#include "Includes.h"

class PositionMatrix
{
private:
  unsigned int _vbo;
  unsigned int _ibo;
  unsigned int _vao;
  unsigned int _numIndices;
  unsigned int _glProgramShader;
  int _swarmSize;
  int _agentIndex;

  float _modelSize;

  glm::vec3 _centerPosition;
  glm::vec2 _sizeMatrix;
  glm::vec3 _minMaxY;
  
  glm::vec3 _startPosition;
  glm::vec3 _speed;

  glm::vec3 _swarmCenter;
  glm::vec3 _moveSpeed;

  glm::mat4 _modelMatrix;
  std::vector<Agent3D*> _swarmReference;

public:

  float _minX, _maxX, _minZ, _maxZ;
  PositionMatrix(unsigned int gl_program_shader, glm::vec2 sizeMatrix, float modelSize)
  {
    _glProgramShader = gl_program_shader;
    _sizeMatrix = sizeMatrix;
    _modelSize = modelSize;
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

  unsigned int getVbo()
  {
    return _vbo;
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
    int currentIndex = 0;
    for (int i = 0; i <= _sizeMatrix.x; i++) {
      indx.push_back(glm::uvec3(0 + currentIndex, 1 + currentIndex, 2 + currentIndex));
      indx.push_back(glm::uvec3(2 + currentIndex, 3 + currentIndex, 0 + currentIndex));
      currentIndex += 4;

      verts.push_back(VertexFormat(_modelSize * i, 0, 0, 0, 0, 1, 1)); // 0       
      verts.push_back(VertexFormat(_modelSize * i + 5, 0, 0, 0, 0, 1, 1)); // 1
      verts.push_back(VertexFormat(_modelSize * i + 5, 0, _modelSize * _sizeMatrix.y, 0, 0, 1, 1)); // 2
      verts.push_back(VertexFormat(_modelSize * i, 0, _modelSize * _sizeMatrix.y, 0, 0, 1, 1)); // 3

    }
    for (int j = 0; j <= _sizeMatrix.y; j++) {
      indx.push_back(glm::uvec3(0 + currentIndex, 1 + currentIndex, 2 + currentIndex));
      indx.push_back(glm::uvec3(2 + currentIndex, 3 + currentIndex, 0 + currentIndex));
      currentIndex += 4;

      verts.push_back(VertexFormat(0, 0, _modelSize * j, 0, 0, 1, 1)); // 0       
      verts.push_back(VertexFormat(_modelSize * _sizeMatrix.x, 0, _modelSize * j, 0, 0, 1, 1)); // 1
      verts.push_back(VertexFormat(_modelSize * _sizeMatrix.x, 0, _modelSize * j + 5, 0, 0, 1, 1)); // 2
      verts.push_back(VertexFormat(0, 0, _modelSize * j + 5, 0, 0, 1, 1)); // 3 
    }

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