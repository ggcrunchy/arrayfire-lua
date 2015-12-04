#ifndef FUNCS_H
#define FUNCS_H

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

int CreateArrayFuncs (lua_State * L);
int Backends (lua_State * L);
int ComputerVision (lua_State * L);
int ImageProcessing (lua_State * L);
int Interface (lua_State * L);
int IO (lua_State * L);
int LinearAlgebra (lua_State * L);
int Math (lua_State * L);
int SignalProcessing (lua_State * L);
int Statistics (lua_State * L);
int Vector (lua_State * L);

#endif // FUNCS_H