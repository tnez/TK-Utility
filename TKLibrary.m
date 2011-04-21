/***************************************************************

 TKLibrary.m
 TKUtility

 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>

 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.

 LastMod: 20100803 - tn

 ***************************************************************/

#import "TKLibrary.h"


@implementation TKLibrary


+ (TKLibrary *)sharedLibrary
{
	static TKLibrary *sharedInstance;

	@synchronized(self)
    {
		if (sharedInstance == NULL){
			sharedInstance = [[self alloc] init];
		}
    }
	return(sharedInstance);
}

-(id)init{
	if([super init]){
		return self;
	}
	return nil;
}

-(void) centerView:(NSView *) theView inWindow:(NSWindow *) theWindow {
	NSRect viewRect = [theView frame];
	NSRect windowRect = [theWindow frame];
	CGFloat newX = (windowRect.size.width-viewRect.size.width)/2 + windowRect.origin.x;
	CGFloat newY = (windowRect.size.height-viewRect.size.height)/2 + windowRect.origin.y;
	NSPoint newOrigin = NSMakePoint(newX, newY);
	[theView setAutoresizesSubviews:NO];
	[theWindow setContentView:theView];
	[theView setFrameOrigin:newOrigin];
        [theWindow makeKeyAndOrderFront:self];
}

-(void) enterFullScreenWithWindow:(NSWindow*)theWindow {

  // hide the menu bar
  [NSMenu setMenuBarVisible:NO];

  // size the window and pop-up
  [theWindow setFrame:[theWindow frameRectForContentRect:
                                   [[theWindow screen] frame]]
              display:YES
              animate:YES];

  // put the window in front and focus
  [theWindow makeKeyAndOrderFront:self];
}

-(void) exitFullScreenWithWindow:(NSWindow *) theWindow {
	[NSMenu setMenuBarVisible:YES];
	[theWindow close];
}

@end
