/***************************************************************
 
 TKSession.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKSession.h"


@implementation TKSession
@synthesize components,date,delegate,prefs,startTimeDesc,startTimeMarker,sessionID,subjectID,task,uuid,window;

-(void) addComponent: (TKComponentController *)newComp {
  [newComp setDelegate: self];
  [components addObject: newComp];
}

-(void) dealloc {
	[components release];
	[date release];
  [startTimeDesc release];
	[sessionID release];
  [subjectID release];
	[task release];
  [uuid release];
  [super dealloc];
}

-(id) init {
  if(self=[super init]) {
    // create unique id
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    [self setUuid:(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef)];
    CFRelease(uuidRef);
		[self setPrefs:[TKPreferences defaultPrefs]];
    [self setComponents:[NSMutableArray array]];
		[self setTask:[prefs valueForKey:@"taskName"]];
    return self;
  }
  return nil;
}

-(void) begin {
	// create timer
	[NSThread detachNewThreadSelector:@selector(spawnAndBeginTimer:) toTarget:[TKTimer class] withObject:nil];
	// load window and go fullscreen
	[NSBundle loadNibNamed:@"TKSessionWindow" owner:self];
	[[TKLibrary sharedLibrary] enterFullScreenWithWindow:window];
	// set start time
	startTimeDesc = [[[NSDate date] description] retain];
	startTimeMarker = current_time_marker();
	// start first component (if any)
	[self attemptToStartNextComponent];
}

-(void) componentDidFinish:(id) sender {
  [components removeObject:sender];
  [self attemptToStartNextComponent];
}

-(void) event:(NSMutableDictionary *) eventInfo didOccurInComponent:(id) sender {
  if([delegate respondsToSelector:@selector(event:didOccurInComponent:)]) {
    // add session data to info
    [eventInfo setValue:sessionID forKey:@"Session"];
    [eventInfo setValue:subjectID forKey:@"Subject"];
		NSDictionary *staticEventInfo = [[NSDictionary dictionaryWithDictionary:eventInfo] retain];
    // send back to delegate
    [delegate event:[staticEventInfo autorelease] didOccurInComponent:sender];
  } else {
    // . . . as needed
  }
}

-(void) end {
	// loop here while there is still logging to be done
	do { sleep(1); } while ([TKLogging unwrittenItemCount] > 0);
	// then...
	// remove the crash recovery file
	[[NSFileManager defaultManager]
	 removeItemAtPath:[[prefs valueForKey:@"dataDirectory"]
										 stringByAppendingPathComponent:
										 [prefs valueForKey:@"crashRecoveryFileName"]] error: nil];
	// close the session window
	[[TKLibrary sharedLibrary] exitFullScreenWithWindow: window];
	[window close];
	if([delegate respondsToSelector:@selector(sessionDidFinish:)]) {
		[delegate sessionDidFinish: nil];
	}
}

-(TKComponentController *) nextComponent {
  return [components objectAtIndex:0];
}

-(void) attemptToStartNextComponent {
  if([components count]>0) {
    [[self nextComponent] begin];
  } else {
    [self end];
  }
}

@end
