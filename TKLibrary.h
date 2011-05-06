/***************************************************************
 
 TKLibrary.h
 TKUtility
 
 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>

@interface TKLibrary : NSObject {
}

/**
   Return a singleton reference to the shared library. This was used
   originally by Scott, and is still in place in order to facilitate
   backwards compatibility with some pieces of the code that make use
   of it.
*/
+ (TKLibrary *)sharedLibrary;

/**
   Center the given view in the given window. This is often called by
   the component controller when loading the component's main view.
 */
-(void) centerView:(NSView *) theView inWindow:(NSWindow *) theWindow;

/**
   Make the given window go full-screen.
*/
-(void) enterFullScreenWithWindow:(NSWindow *) theWindow;

/**
   Exit full-screen with the window. This will also restore the apple
   menu bar, which closing the window alone does not.
 */
-(void) exitFullScreenWithWindow:(NSWindow *) theWindow;

@end
