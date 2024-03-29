#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "secp256k1.h"
#import "secp256k1_ecdh.h"
#import "secp256k1_extrakeys.h"
#import "secp256k1_preallocated.h"
#import "secp256k1_recovery.h"
#import "secp256k1_schnorrsig.h"

FOUNDATION_EXPORT double Secp256k1KitVersionNumber;
FOUNDATION_EXPORT const unsigned char Secp256k1KitVersionString[];

