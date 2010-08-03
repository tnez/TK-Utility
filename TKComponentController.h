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

@interface TKComponentController : NSObject {
  TKTime componentStartTime;
  TKTime componentEndTime;
  id delegate;
	NSString *nibFileName;
	IBOutlet NSView *view;
}
@property(readwrite) TKTime componentStartTime;
@property(readwrite) TKTime componentEndTime;
@property(assign) id delegate;
@property(nonatomic, retain) NSString *nibFileName;
@property(assign) IBOutlet NSView *view;
-(void) begin;					 // should be overridden in subclass
-(void) end;						 // should be overridden in subclass
-(void) loadPreferences; // should be overridden in subclass
-(void) loadView;
-(void) preferencesDidChange:(NSNotification *) theNote;
-(void) throwError:(NSString *) errorDescription andBreak:(BOOL) shouldBreak;
@end
// DELEGATE METHODS - These messages will be sent to delegate (if any)
@interface NSObject (TKComponentControllerDelegate)
-(void) componentDidFinish:(id) sender;
-(void) event:(NSMutableDictionary *) eventInfo didOccurInComponent:(id) sender;
-(void) breakWithMessage:(NSString *) errorDescription fromComponent:(id) sender;
@end
