/***************************************************************
 
 TKWaitController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn

 ***************************************************************/

#import "TKWaitController.h"


@implementation TKWaitController
@synthesize view,button,text;

-(void) dealloc {
  [super dealloc];
}

-(void) begin {
  // load nib
  [NSBundle loadNibNamed:@"TKWaitView" owner:self];
  // bring up view
  [[delegate window] setContentView:view];
  // record start time
  [self setComponentStartTime:current_time_marker()];
}

-(id) init {
  if(self=[super init]) {
    // . . .
    return self;
  } else {
    return nil;
  }
}

-(IBAction) submit:(id) sender {
  // record end time
  [self setComponentEndTime:current_time_marker()];
  // notify delegate that we are done
  [delegate componentDidFinish: self];
}

+(id) waitComponent {
  TKWaitController *newWaitController;
  if(newWaitController=[[TKWaitController alloc] init]) {
    return [newWaitController autorelease];
  } else {
    return nil;
  }
}

@end
