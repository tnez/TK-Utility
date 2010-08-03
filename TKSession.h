/***************************************************************
 
 TKSession.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 IN (Information To Be Provided By Preferences)
 --------------------------------------------------------------
 crashRecoveryFileName (optional)
 dataDirectory
 taskName
 
 OUT (Event Information)
 --------------------------------------------------------------
 Session
 Subject
 
 ***************************************************************/


#import <Cocoa/Cocoa.h>
#import "TKComponentController.h"
#import "TKLibrary.h"
#import "TKLogging.h"
#import "TKPreferences.h"
#import "TKTime.h"

@interface TKSession : NSObject {
	id delegate;
	TKPreferences *prefs;
  IBOutlet id window;
  NSMutableArray *components;
	NSString *date;
	NSString *task;
	NSString *sessionID;
	NSString *subjectID;
  NSString *uuid;
  TKTimer *sharedTimer;
  TKTime startTimeMarker;
  NSString *startTimeDesc;
}
@property(assign) id delegate;
@property(assign) TKPreferences *prefs;
@property(assign) IBOutlet id window;
@property(nonatomic, retain) NSMutableArray *components;
@property(nonatomic, retain) NSString *date;
@property(nonatomic, retain) NSString *task;
@property(nonatomic, retain) NSString *sessionID;
@property(nonatomic, retain) NSString *subjectID;
@property(nonatomic, retain) NSString *uuid;
@property(readonly) TKTime startTimeMarker;
@property(readonly) NSString *startTimeDesc;
-(void) addComponent:(TKComponentController *) newComp;
-(void) attemptToStartNextComponent;
-(void) begin;
-(void) componentDidFinish:(id) sender;
-(void) end;
-(void) event:(NSMutableDictionary *) eventInfo didOccurInComponent:(id) sender;
-(TKComponentController *) nextComponent;
@end

// DELEGATE METHODS //
@interface NSObject (TKSessionDelegate)
-(void) event:(NSDictionary *) eventInfo didOccurInComponent:(id) sender;
-(void) sessionDidBegin:(NSNotification *) note;
-(void) sessionDidFinish:(NSNotification *) note;
-(void) sessionDidPause:(NSNotification *) note;
-(void) sessionDidResume:(NSNotification *) note;
@end
