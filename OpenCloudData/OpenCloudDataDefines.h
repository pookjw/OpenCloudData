//
//  OpenCloudDataDefines.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#ifndef _OPENCLOUDDATADEFINES_H
#define _OPENCLOUDDATADEFINES_H

//
// For MACH
//

#if defined(__MACH__)

#ifdef __cplusplus
#define OC_EXTERN        extern "C"
#define OC_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern "C"
#else
#define OC_EXTERN        extern
#define OC_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern
#endif

#endif

#endif // _OPENCLOUDDATADEFINES_H
