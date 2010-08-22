/***************************************************************
 
 TKComponentController.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>
#import "TKLibrary.h"
#import "TKTime.h"

#pragma mark Preference Keys
#define TK_COMPONENT_TYPE_KEY @"TKComponentTypeKey"
#define TK_COMPONENT_NIB_FILE_NAME_KEY @"TKComponentNibFileName"

@interface TKComponentController : NSObject {
	TKTime componentStartTime;
	TKTime componentEndTime;
	id delegate;
	IBOutlet NSView *view;
    NSDictionary *definition;
    NSString *componentType;
}
@property (readonly) TKTime componentStartTime;
@property (readonly) TKTime componentEndTime;
@property (assign) id delegate;
@property (assign) IBOutlet NSView *view;
@property (nonatomic, copy) NSDictionary *definition;
@property (nonatomic, retain) NSString *componentType;
-(void) begin;					 // should be overridden in subclass
-(void) end;					 // should be overridden in subclass, then passed to super
+(id) loadFromDefinition:(NSDictionary *) newDefinition sender:(id) sender;
-(void) loadDefinition:(NSDictionary *) newDefinition;
-(void) loadPreferences;		 // should be overridden in subclass
-(void) loadView;
-(void) throwError:(NSString *) errorDescription andBreak:(BOOL) shouldBreak;
@end
// DELEGATE METHODS - These messages will be sent to delegate (if any)
@interface NSObject (TKComponentControllerDelegate)
-(void) componentDidFinish:(id) sender;
-(void) event:(NSMutableDictionary *) eventInfo didOccurInComponent:(id) sender;
-(void) breakWithMessage:(NSString *) errorDescription fromComponent:(id) sender;
@end
