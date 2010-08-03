/***************************************************************
 
 TKWaitController.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>
#import "TKComponentController.h"

@interface TKWaitController : TKComponentController {
  IBOutlet id button;
  IBOutlet id text;
}
@property (assign) IBOutlet id button;
@property (assign) IBOutlet id text;
-(void) begin;
-(IBAction) submit:(id) sender;
+(id) waitComponent;
@end
