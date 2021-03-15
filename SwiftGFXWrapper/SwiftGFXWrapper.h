//
//  SwiftGFXWrapper.h
//  SwiftGFXWrapper
//
//  Created by Tanner W. Stokes on 1/3/21.
//

#import <Foundation/Foundation.h>

//! Project version number for SwiftGFXWrapper.
FOUNDATION_EXPORT double SwiftGFXWrapperVersionNumber;

//! Project version string for SwiftGFXWrapper.
FOUNDATION_EXPORT const unsigned char SwiftGFXWrapperVersionString[];

// clear out the variable modifier used in the library
// since we don't have the PROGMEM Arduino functions
#define PROGMEM

#import "VirtualDotMatrixWrapper.h"
#import "Fonts.h"
