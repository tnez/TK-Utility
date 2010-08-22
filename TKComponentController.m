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
@synthesize componentStartTime,componentEndTime,componentType,definition,delegate,view;

-(void) begin {
    [self loadView];
    componentStartTime = current_time_marker();
}

-(void) closeView {
	// ... nothing needed as of now
}

-(void) dealloc {
    [definition release];
    [componentType release];
	[super dealloc];
}

-(void) end {
    componentEndTime = current_time_marker();
    [view exitFullScreenModeWithOptions:nil];
    if([delegate respondsToSelector:@selector(componentDidFinish:)]) {
        [delegate componentDidFinish:self];
    }
}

+(id) loadFromDefinition:(NSDictionary *) newDefinition sender:(id) sender {
    // create new instance
    TKComponentController *newComponent = [[TKComponentController alloc] init];
    // configure new component
    [newComponent loadDefinition:newDefinition];
    [newComponent setDelegate:sender];
    [NSBundle loadNibNamed:[newDefinition valueForKey:TK_COMPONENT_NIB_FILE_NAME_KEY] owner:newComponent];
    return [newComponent autorelease];
}

-(void) loadDefinition:(NSDictionary *) newDefinition {
    [self setDefinition:newDefinition];
}
    
-(void) loadView {
	if([delegate respondsToSelector:@selector(window)]) {
		[[TKLibrary sharedLibrary] centerView:view inWindow:[delegate window]];
	} else {
        [self throwError:@"Could not load view" andBreak:YES];
	}
}

-(void) loadPreferences {
    // each sub-class should implement a loadPreferences function and
    // call [super loadPreferences] before closing to pass on up the chain
    [self setComponentType:[definition valueForKey:TK_COMPONENT_TYPE_KEY]];
    // this is the end of the chain
}

-(void) throwError:(NSString *) errorDescription andBreak:(BOOL) shouldBreak {
	NSLog(@"%@: %@",[self class],errorDescription);
	if(shouldBreak) {
		if([delegate respondsToSelector:@selector(breakWithMessage:fromComponent:)]) {
			[delegate breakWithMessage:errorDescription fromComponent:self];
		}
	}
}

@end
