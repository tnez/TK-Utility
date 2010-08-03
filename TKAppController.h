/***************************************************************
 
 TKAppController.h
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
 dataFileName
 setupFileName (optional)
 shouldRunOnLaunch (optional)
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>
#import "TKDelimitedFileParser.h"
#import "TKLogging.h"
#import "TKPreferences.h"
#import "TKSession.h"


@interface TKAppController : NSObject {
	NSNotificationCenter *postOffice;
	TKLogging *mainLogger;
	TKLogging *crashLogger;
	TKPreferences *preferences;
	TKSession *session;
}
@property (assign) TKLogging *mainLogger;
@property (assign) TKLogging *crashLogger;


// ANY OF THESE FUNCTIONS CAN BE OVERRIDDEN IF MORE SPECIFIC BEHAVIOR IS NEEDED
// - THE FOLLOWING FUNCTIONS MAY BE CONSIDERED THE DEFAULT BEHAVIOR OF THE
//   TK_APPLICATION
// - TK_APP_CONTROLLER IS INTENDED TO BE SUB-CLASSED AND EXTENDED
// 
-(void) addDefaultSessionHeaderIfNeeded;
-(void) addDefaultRunHeaderIfNeeded;
-(void) alertWithMessage:(NSString *) message;
-(void) applicationDidBecomeActive:(NSNotification *) notification;
-(void) applicationDidFinishLaunching:(NSNotification *) notification;
-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app;
-(void) applicationWillTerminate:(NSNotification *) notification;
-(void) beginSession;
-(void) dealloc;
-(BOOL) didLoadDefaultSetupInfo; // utility function to make life easier -
																 // loads default setup and returs success(yes/no)
																 // is not called unless explicitly called in
																 // sub-class
-(BOOL) directoryExistsAtPath:(NSString *) directoryPath;
-(void) event:(NSDictionary *) eventInfo didOccurInComponent:(id) sender;
-(BOOL) fileExistsAtPath:(NSString *) filePath;
-(id) init;
-(BOOL) isClearedToBeginSession; // should be overridden in sub-class
																 // default provides no error checking
-(void) loadPreferences;
-(void) loadSession;						 // should be overridden in sub-class
																 // this is where components will be loaded
																 // into session
-(BOOL) needsToRecoverFromCrash;
-(IBAction) newSession:(id) sender;
-(IBAction) openPreferencesWindow:(id) sender;
-(IBAction) quit:(id) sender;
-(void) recoverFromCrash;				 // must be overridden if needed
-(void) sessionDidBegin:(NSNotification *) note;  // can be overridden
-(void) sessionDidFinish:(NSNotification *) note; // can be overridden -
																									// calls unloadSession, then
																									// gives back session resources
																									// and closes window
+(TKAppController *) sharedAppController;
-(void) startLogs;
-(void) unloadSession;					 // must be overridden if needed
@end
