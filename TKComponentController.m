/***************************************************************
 
 TKComponentController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKComponentController.h"


@implementation TKComponentController
@synthesize componentStartTime,componentEndTime,delegate,nibFileName,view;

-(void) begin {
	//
	return;
}

-(void) closeView {
	// ... nothing needed as of now
}

-(void) dealloc {
	[nibFileName release];
  [super dealloc];
}

-(void) end {
	[delegate componentDidFinish: self];
	return;
}

-(void) loadView {
	if([delegate respondsToSelector:@selector(window)]) {
		[[TKLibrary sharedLibrary] centerView:view inWindow:[delegate window]];
	} else {
		NSLog(@"Error: Could not load view in: %@",[self className]);
	}
}

-(void) loadPreferences {
	// should be overridden in subclass
	return;
}

-(void) preferencesDidChange:(NSNotification *) aNotefification {
	[self loadPreferences];
}

-(void) throwError:(NSString *) errorDescription andBreak:(BOOL) shouldBreak {
	NSLog(@"TKVasCotroller: ",errorDescription);
	if(shouldBreak) {
		[delegate breakWithMessage: errorDescription fromComponent: self];
	} else {
		 // ...
	}
}

@end
