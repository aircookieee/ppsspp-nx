// Copyright (C) 2003 Dolphin Project.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 2.0 or later versions.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License 2.0 for more details.

// A copy of the GPL 2.0 should have been included with the program.
// If not, see http://www.gnu.org/licenses/

// Official SVN repository and contact information can be found at
// http://code.google.com/p/dolphin-emu/


// This header contains type definitions that are shared between the Dolphin core and
// other parts of the code. Any definitions that are only used by the core should be
// placed in "Common.h" instead.

#pragma once

#if defined(_MSC_VER)

#define NO_INLINE __declspec(noinline)

typedef unsigned __int8 u8;
typedef unsigned __int16 u16;
typedef unsigned __int32 u32;
typedef unsigned __int64 u64;

typedef signed __int8 s8;
typedef signed __int16 s16;
typedef signed __int32 s32;
typedef signed __int64 s64;

#else

#define NO_INLINE __attribute__((noinline))

#ifdef __SWITCH__
// Avoid name conflicts with libnx symbols
#define Event _Event
#define Framebuffer _Framebuffer
#define Waitable _Waitable
#define ThreadContext _ThreadContext
#define BreakReason _BreakReason
#include <switch.h>
// Cleanup libnx name conflicts
#undef Event
#undef Framebuffer
#undef Waitable
#undef ThreadContext
// BIT(n) macro from libnx conflicts with PPSSPP's BIT() method
#undef BIT
// BreakReason from libnx conflicts with PPSSPP's enum
#undef BreakReason

typedef unsigned char   u_char;
typedef unsigned short  u_short;
typedef unsigned int    u_int;
typedef unsigned long   u_long;

// libnx already typedefs u8/u16/u32/u64/s8/s16/s32/s64 via switch/types.h.
// On aarch64, libnx uses 'unsigned long' for u64 and 'signed long' for s64,
// while PPSSPP normally uses 'unsigned long long' / 'signed long long'.
// Both are 64-bit on LP64 but are different types in C/C++.
// We simply reuse libnx's typedefs to avoid conflicts.

#else // !__SWITCH__

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;

#endif // __SWITCH__

#endif // _WIN32
