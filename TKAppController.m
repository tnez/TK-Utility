/***************************************************************
 
 TKAppController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKAppController.h"


@implementation TKAppController

@synthesize mainLogger, crashLogger;

-(void) addDefaultSessionHeaderIfNeeded {
	NSString *datafile = [[preferences valueForKey:@"dataDirectory"] stringByAppendingPathComponent:[preferences valueForKey:@"dataFileName"]];
	if(![self fileExistsAtPath:datafile]) {
		NSString *header = [[NSString alloc] initWithFormat:@"Task:\t%@\tSubject ID:\t%@\tSession#:\t%@\tDate:\t%@",
												[session task],[session subjectID],[session sessionID],[session date]];
		[[TKLogging mainLogger] logString: [header autorelease]];
	} else {
		// . . .
	}
	return;
}

-(void) addDefaultRunHeaderIfNeeded {
	// get run count
	NSInteger count = 0;
	NSString *path = [[[preferences valueForKey:@"dataDirectory"]
										 stringByAppendingPathComponent:[preferences valueForKey:@"dataFileName"]] retain];
	TKDelimitedFileParser *pdf = [[TKDelimitedFileParser alloc]	initParserWithFile:path
																																	 usingEncoding:TKDELIM_DEFAULT_ENCODING
																														 withRecordDelimiter:@"\n"
																															withFieldDelimiter:@"\t"];
	for(id record in [pdf records]) {
		if([[record objectAtIndex:0] isEqualToString:@"Run:"]) {
			count++;
		}
	}
	NSString *runHeader = [[NSString alloc] initWithFormat:@"Run:\t%d\t%@",
												 count+1,
												 [[NSDate date] description]];
	[[TKLogging mainLogger] insertGroupDelimiter];
	[[TKLogging mainLogger] logString:[runHeader autorelease]];
	[path release];
	[pdf release];
}

-(void) alertWithMessage:(NSString *) message {
	[[NSAlert alertWithMessageText:@"Error:"
									 defaultButton:nil
								 alternateButton:nil
										 otherButton:nil
			 informativeTextWithFormat:message] runModal];
}

-(void) applicationDidBecomeActive:(NSNotification *) notification {
	
}

-(void) applicationDidFinishLaunching:(NSNotification *) notification {
	[self loadPreferences];
	if([self needsToRecoverFromCrash] || [preferences valueForKey:@"shouldRunOLaunch"]) {
		[self newSession: self];
	} else {
		// no action needed
	}
}

-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app {
	return (NSInteger)[TKLogging unwrittenItemCount] == 0;
}

-(void) applicationWillTerminate:(NSNotification *) notification {

}

-(void) beginSession {
	[self startLogs];
	[self addDefaultSessionHeaderIfNeeded];
	[self addDefaultRunHeaderIfNeeded];
	[session begin];
}
		
-(void) dealloc {
	[session release];
	[super dealloc];
}

-(BOOL) didLoadDefaultSetupInfo {
	NSString *fullpath = [[preferences valueForKey:@"dataDirectory"] stringByAppendingPathComponent:[preferences valueForKey:@"setupFileName"]];
	TKDelimitedFileParser *setup = [TKDelimitedFileParser parserWithFile:fullpath
																									 withRecordDelimiter:@"\n"
																										withFieldDelimiter:@"\t"];
	if(setup) {
		[setup setIsKeyValueSet:YES];
		// load information into session
		[session setTask:[preferences valueForKey:@"taskName"]];
		[session setSubjectID:[setup valueForKey:@"Subject ID"]];
		[session setSessionID:[setup valueForKey:@"Study Day"]];
		[session setDate:[setup valueForKey:@"Date"]];
		return YES;
	} else {
		return NO;
	}
}

-(BOOL) directoryExistsAtPath:(NSString *) directoryPath {
	BOOL exists, isDirectory;
	exists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];
	return (exists && isDirectory);
}

-(void) event:(NSDictionary *) eventInfo didOccurInComponent:(id) sender {
	return; // do nothing by default - must be overridden
}

-(BOOL) fileExistsAtPath:(NSString *) filePath {
	BOOL exists, isDirectory;
	exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
	return (exists && !isDirectory);
}

-(id) init {
	if(self=[super init]) {
		preferences = [TKPreferences defaultPrefs];
		postOffice = [NSNotificationCenter defaultCenter];
		[postOffice addObserver:self
									 selector:@selector(loadPreferences)
											 name:@"preferencesDidChange"
										 object:nil];
		[[NSApplication sharedApplication] setDelegate:self];
		return self;
	} else {
		return nil;
	}
}

-(BOOL) isClearedToBeginSession {
	return YES; // default behavior unless overridden
}

-(void) loadPreferences {
	if(preferences) {
		if(mainLogger) {
			[mainLogger setDataDirectory:[preferences valueForKey:@"dataDirectory"]];
			[mainLogger setFileName:[preferences valueForKey:@"dataFileName"]];
		}
		if(crashLogger) {
			[crashLogger setDataDirectory:[preferences valueForKey:@"dataDirectory"]];
			[crashLogger setFileName:[preferences valueForKey:@"crashRecoveryFileName"]];
		}
	} else {
		[self alertWithMessage:@"Could not load preferences!"];
	}
}

-(void) loadSession {

}

-(BOOL) needsToRecoverFromCrash {
	// ...if crash recovery file exists
	return [[NSFileManager defaultManager]
					fileExistsAtPath:[[preferences valueForKey:@"dataDirectory"]
														stringByAppendingPathComponent:
														[preferences valueForKey:@"crashRecoveryFileName"]]];
}

-(IBAction) newSession:(id) sender {
	// run wait screen as modal alert
	NSAlert *alert =
		[NSAlert alertWithMessageText:@"Waiting To Begin:"
										defaultButton:@"Begin"
									alternateButton:@"Cancel"
											otherButton:nil
				informativeTextWithFormat:@"Click when you are ready to begin your session"];
	NSInteger response = [alert runModal];
	if(response==NSAlertAlternateReturn) {
		// user cancel...
	} else { // the user has selected to begin the session...
		//... create the session
		session = [[TKSession alloc] init];
		[session setDelegate: self];
		// check if we are cleared to begin
		if([self isClearedToBeginSession]) {
			if([self needsToRecoverFromCrash]) {
				// recover from crash if needed
				[self recoverFromCrash];
			}
			// then load and begin
			[self loadSession];
			[self beginSession];
		} else {
			[session release]; session = nil;
			[self alertWithMessage:@"Session is not cleared to begin: review preferences and/or setup and try again."];
		}
	}
}

-(IBAction) openPreferencesWindow:(id) sender {
	if(!session) {
		[preferences open: self];
	} else {
		[self alertWithMessage:@"Cannot open preferences while session is active!"];
	}
}

-(IBAction) quit:(id) sender {
	if(!session) {
		[[NSApplication sharedApplication] terminate: self];
	} else {
		[self alertWithMessage:@"Cannot quit while session is in progress!"];
	}
}

-(void) recoverFromCrash {
	[self alertWithMessage:@"Crash Recovery Information found, but no method provided by which to recover!"];
	return; // must be overridden in sub-class
}	
	
-(void) sessionDidBegin:(NSNotification *) note {
	// ...
}

-(void) sessionDidFinish:(NSNotification *) note {
	[self unloadSession];
}

+(TKAppController *) sharedAppController {
	return [[NSApplication sharedApplication] delegate];
}

-(void) startLogs {
	if([preferences valueForKey:@"dataDirectory"] && [preferences valueForKey:@"dataFileName"]) {
		// start main logger
		[NSThread detachNewThreadSelector:@selector(spawnMainLogger:) toTarget:[TKLogging class] withObject:nil];
		[[TKLogging mainLogger] setDataDirectory:[preferences valueForKey:@"dataDirectory"]];
		[[TKLogging mainLogger] setFileName:[preferences valueForKey:@"dataFileName"]];
		[self setMainLogger:[TKLogging mainLogger]];
	}
	if([preferences valueForKey:@"dataDirectory"] && [preferences valueForKey:@"crashRecoveryFileName"]) {
		// start crash recovery logger
		[NSThread detachNewThreadSelector:@selector(spawnCrashRecoveryLogger:) toTarget:[TKLogging class] withObject:nil];
		[[TKLogging crashRecoveryLogger] setDataDirectory:[preferences valueForKey:@"dataDirectory"]];
		[[TKLogging crashRecoveryLogger] setFileName:[preferences valueForKey:@"crashRecoveryFileName"]];
		[self setCrashLogger:[TKLogging crashRecoveryLogger]];
	}
}

-(void) unloadSession {
	[session release], session=nil;
}

@end
