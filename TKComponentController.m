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
#import "TKComponentCocoaApp.h"
#import "TKSession.h"

@implementation TKComponentController
@synthesize delegate,definition,timer,mainLog,crashLog,subject,sessionWindow,componentStartTime,componentEndTime;

-(void) begin {

    // if we are not cleared to begin, then exit
    if(![self isClearedToBegin]) { return; }
    // ...else proceed

    // send notification that we are about to begin
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentWillBeginNotification object:self];

    // grab references to logs and timers
    [self setTimer:[TKTimer appTimer]];
    [self setMainLog:[TKLogging mainLogger]];
    [self setCrashLog:[TKLogging crashRecoveryLogger]];
  
    // reset counts for main and crash logs
    [mainLog setCount:0];
    [crashLog setCount:0];

    // begin component according to component type
    switch ([[definition valueForKey:TKComponentTypeKey] integerValue]) {

        case TKComponentTypeCocoaBundle:
            // load bundle and get instantiate principal class
            component = [[[BUNDLE principalClass] alloc] init];
            if([component conformsToProtocol:@protocol(TKComponentBundleLoading)]) {
                [component setDefinition:definition];   // set definition for comp
                [component setDelegate:self];           // register as delegate for new component
                if([component shouldRecover]) {         // if component needs to recover
                    [component recover];                // ...recover
                } else {                                // otherwise,
                    [component setup];                  // ...perform normal setup
                }
                if([component isClearedToBegin]) {          // if component is good to go...
                    [self loadView:[component mainView]];   // - pull up the view in session window
                    [component begin];                      // - begin component
                } else {
                    [self throwError:@"Component does not conform to bundle loading protocol" andBreak:YES];
                }
            } else { // the bundle did not load
                [self throwError:@"Could not load specified bundle" andBreak:YES];
            }
            break;

      case TKComponentTypeCocoaApplication:
        // load the bundle
        component = [[TKComponentCocoaApp alloc]
                     initWithDefinition:definition];
        [component setDelegate:self];
        // if component is cleared to begin...
        if([component isClearedToBegin]) {
          // begin
          [component begin];
        } else { // throw error
          [self throwError:@"Could not load specified cocoa application"
                  andBreak:YES];
        }
        break; // end of begin cocoa application

        case TKComponentTypeFutureBasicApplication:
            // TODO: load future basic application
            [self throwError:@"Cannot load Future Basic applications (support is coming soon)" andBreak:YES];
            break;

        default:
            [self throwError:@"Specified component type is not recognized" andBreak:YES];
    }
    componentStartTime = current_time_marker();
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentDidBeginNotification object:self];
}

- (void)componentDidFinish: (id)sender {
    // if this is a loadable component bundle that just finished
    if([component conformsToProtocol:@protocol(TKComponentBundleLoading)]) {
      // remove UI from view
      [[component mainView] removeFromSuperview];
      // SESSION HEADER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if([self runCount] == 1) {
        // get session header
        NSString *_sessionHead = [self sessionHeader];
        // get offset value for session header (jic we need it later)
        sessionHeaderOffset = [_sessionHead lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        // write the session header
        [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:_sessionHead overWriteOnFirstWrite:NO];
      } else {}
      // SUMMARY ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      NSString *_summary = [self summary];        // get summary
      if(_summary)                                // if summary exists...
      {                                           
        // get length of summary in bytes  
        NSUInteger _length = [_summary lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSUInteger _offset = [self summaryOffset]; // get the offset value
        // get last summary end offset
        NSUInteger _lastSummaryEnd = [[[self registryForTaskWithOffset:0] valueForKey:TKComponentSummaryEndKey] unsignedIntegerValue];
        // if this is not first run and new summary takes up more space than last...
        DLog(@"THIS IS THE NEW FRAMEWORK!!!");
        DLog(@"Last summary end: %d",_lastSummaryEnd);
        DLog(@"Length + Offset: %d",_length+_offset);
        if([self runCount]!=1 && (_lastSummaryEnd != (_length + _offset)))
        {
          // get new offset value of where old content should be placed
          NSNumber *shoveOffset = [NSNumber numberWithUnsignedInteger:_length + _offset];
          // get comeplete old logfile
          NSFileHandle *df = [NSFileHandle fileHandleForReadingAtPath:PATH_TO_DATAFILE];
          // seek to old end of summary
          [df seekToFileOffset:_lastSummaryEnd];
          // read from old offset to eof
          NSData *oldData = [df readDataToEndOfFile];
          // get string from oldData
          NSString *oldStr = [[NSString alloc] initWithData:oldData encoding:NSUTF8StringEncoding];
          DLog(@"Shoving offset for detailed data: %d",[shoveOffset intValue]);
          // re-write old string at new offset
          [mainLog queueLogMessage:DATADIRECTORY file:DATAFILE contentsOfString:[oldStr autorelease] overWriteOnFirstWrite:NO withOffset:shoveOffset];
        }
        // now we can write the summary at offset point
        NSNumber *offset = [NSNumber numberWithUnsignedInteger:_offset];
        [mainLog queueLogMessage:DATADIRECTORY file:DATAFILE contentsOfString:_summary overWriteOnFirstWrite:NO withOffset:offset];
        // record (new) last summary  start and end
        [self setValue:[NSNumber numberWithUnsignedInteger:_offset] forRegistryKey:TKComponentSummaryStartKey];
        [self setValue:[NSNumber numberWithUnsignedInteger:_length + _offset] forRegistryKey:TKComponentSummaryEndKey];
      }
      // RUN HEADER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if([component respondsToSelector:@selector(runHeader)]) { // custom run header
        [mainLog writeToDirectory:[self dataDirectory] file:DATAFILE contentsOfString:[component runHeader] overWriteOnFirstWrite:NO];
      } else { // use default run heaer
        [mainLog writeToDirectory:[self dataDirectory] file:DATAFILE contentsOfString:DEFAULT_RUN_HEADER overWriteOnFirstWrite:NO];
      }
      // wait for log queue to clear
      while([TKLogging unwrittenItemCount] > 0) {
        DLog(@"TKComponentController waiting for log queue to clear before finalizing data file");
      }
      // DETAILED DATA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      NSString *rawData = [NSString stringWithContentsOfFile:[TEMPDIRECTORY stringByAppendingPathComponent:[component rawDataFile]]];
      [mainLog writeToDirectory:[self dataDirectory] file:DATAFILE contentsOfString:rawData overWriteOnFirstWrite:NO];
      // clean up component -- it is the component's responsibility to remove it's temporary files (raw data file included)
      [component tearDown];
      [component release];
    } 
  // if this is a cocoa app that has finished...
  if([[definition valueForKey:TKComponentTypeKey] integerValue] ==
     TKComponentTypeCocoaApplication) {
    // then it is time to tear down
    [component tearDown];
    [component release];
  } // end of cocoa app cleanup
    
  [self end];
}

- (NSString *)dataDirectory {
  if([component respondsToSelector:@selector(dataDirectory)] &&
     [component dataDirectory]!=nil) {
    return [component dataDirectory];   // if the component wishes to override
                                        // the data directory, return the
                                        // component's data directory
  } else {
    return [delegate dataDirectory];    // otherwise, return the delegate's
                                        // data directory
  }
}

-(void) dealloc {
    [definition release];
	[super dealloc];
}

- (NSString *)defaultTempFile {
    return TEMPFILE;
}

- (TKSession *)delegate {
  return delegate;
}

-(void) end {
    componentEndTime = current_time_marker();
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentDidFinishNotification object:self];
}

- (id)init {
  if(self=[super init]) {
    sessionHeaderOffset = 0;
    lastSummaryEnd = 0;
    return self;
  }
  return nil;
}

- (BOOL)isClearedToBegin {
    // right now there is no error checking for the super class
    return YES;
}

+ (id)loadFromDefinition: (NSDictionary *)newDefinition {
    // create new instance
    TKComponentController *newInstance = [[TKComponentController alloc] init];
    // give component definition
    [newInstance setDefinition:newDefinition];
    // return component
    return [newInstance autorelease];
}

- (void)logStringToDefaultTempFile: (NSString *)theString {
    [self logString:theString toDirectory:[self tempDirectory] toFile:[self defaultTempFile]];
}

- (void)logString: (NSString *)theString toDirectory: (NSString *)theDirectory toFile: (NSString *)theFile {
    [mainLog queueLogMessage:[theDirectory stringByStandardizingPath] file:theFile contentsOfString:[theString stringByAppendingString:@"\n"] overWriteOnFirstWrite:NO];
}
- (void)loadView: (NSView *)view {
    // go fullscreen with session window
    [[TKLibrary sharedLibrary] enterFullScreenWithWindow:sessionWindow];
    // load and center the view
    [[TKLibrary sharedLibrary] centerView:view inWindow:sessionWindow];
}

- (NSString *)preflightAndReturnErrorAsString {

    switch ([[definition valueForKey:TKComponentTypeKey] integerValue]) {
        case TKComponentTypeCocoaBundle:
            // load component
            component = [[[BUNDLE principalClass] alloc] init];
            if([component conformsToProtocol:@protocol(TKComponentBundleLoading)]) {
                [component setDefinition:definition];   // 1) set definition for comp
                [component setup];                      // 2) internal setup for comp
                if([[component errorLog] isEqualToString:@""]) {      // -  if component is good to go...
                    return @"Bundle Successfully Loaded (No Errors Reported)\n";
                } else {
                    return [component errorLog];
                }
            } else { // component does not conform to required protocol
                return @"Bundle does not conform to required protocol\n";
            }
            // we called setup... so we best call tear down
            [component tearDown];
            [component release]; component = nil;
            break;
        case TKComponentTypeCocoaApplication:
            // TODO: implement preflight for cocoa app
            return nil;
            break;
        case TKComponentTypeFutureBasicApplication:
            // TODO: implement preflight for future basic app
            return nil;
            break;
        default:
            return @"Invalid component type\n";
            break;
    }
}

/**
 Return registry corresponding to given task ID... returns nil if not found.
 */
- (NSDictionary *)registryForTask: (NSString *)taskID {
  return [delegate registryForTask:taskID];
}

/**
 Return registry for the last completed task
 */
- (NSDictionary *)registryForLastTask {
  return [delegate registryForLastTask];
}

/**
 Return registry for the task using the given offset value
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there
 */
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset {
  return [delegate registryForTaskWithOffset:offset];
}

/**
 Return registry for run with offset for a given task ID
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there 
 */
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                                   forTask: (NSString *)taskID {
  return [self registryForRunWithOffset:offset forTaskRegistry:
          [delegate registryForTask:taskID]];
}

/**
 Return registry for run with offset for a given task registry
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there
 */
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                           forTaskRegistry: (NSDictionary *)taskRegistry {
  NSDictionary *retValue = nil;
  @try {
    // create a target index value
    NSInteger targetIdx;
    // get runs dictionary
    NSArray *allRuns = [taskRegistry valueForKey:TKComponentRunKey];
    // if we're working recent to old...
    if(offset < 0) {
      // target index is runs count - 1 + offset
      targetIdx = [allRuns count] - 1 + offset;
    }
    // if we're working old to recent...
    if(offset > 0) {
      // target index is equal to offset - 1
      targetIdx = offset - 1;
    }
    // if offset is zero, then we want the current run
    if(offset == 0) {
      // target index is one less runs count
      targetIdx = [allRuns count] - 1;
    }
    // now that we have determined our target index, we can grab out retValue
    retValue = [allRuns objectAtIndex:targetIdx];
  }
  @catch (NSException * e) {
    NSLog(@"Could not get run with offset: %d from task registry: %@",
          offset,[taskRegistry description]);
  }
  @finally {
    return retValue;
  }
}

/**
 Return registry for last run of given task ID
 */
- (NSDictionary *)registryForLastRunForTask: (NSString *)taskID {
  return [self registryForRunWithOffset:-1 forTaskRegistry:
          [delegate registryForTask:taskID]];
}

/**
 Return registry for last run of given task registry
 */
- (NSDictionary *) registryForLastRunForTaskRegistry:
                      (NSDictionary *)taskRegistry {
  return [self registryForRunWithOffset:-1 forTaskRegistry:taskRegistry];
}

- (NSInteger) runCount {
  NSInteger retValue;
  @try {
  retValue = [[[delegate registryForTaskWithOffset:0]
               valueForKey:TKComponentRunKey] count];
  }
  @catch (NSException * e) {
    NSLog(@"Unable to determine the run count");
    retValue = -1;
  }
  @finally {
    return retValue;
  }
}

- (NSString *)runHeader {
  if([component respondsToSelector:@selector(runHeader)]) {
    return [component runHeader];
  }
  return DEFAULT_RUN_HEADER;
}

- (void)setDefinition: (NSDictionary *)newDefinition {
    [definition release];
    definition = [[NSDictionary alloc] initWithDictionary:newDefinition];
}

- (NSString *)shortdate {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy_MM_dd"];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)session {
    return SESSION;
}

- (NSString *)sessionHeader {
  if([component respondsToSelector:@selector(sessionHeader)]) {
    return [component sessionHeader];
  } // else, return default
  return DEFAULT_SESSION_HEADER;
}

/**
 Set value for given key for the global registry key of this current task
 */
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key {
  DLog(@"Sending:(setValue:%@ forRegistryKey:%@) to my delegate:%@",
        newValue,key,delegate);
  [delegate setValue:newValue forRegistryKey:key];
  
}

/**
 Set value for given key for the current run of the current task
 */
- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key {
  [delegate setValue:newValue forRunRegistryKey:key];
}

- (TKTime)startTime {
    return componentStartTime;
}

- (NSString *)summary {
  if([component respondsToSelector:@selector(summary)]) {
    return [component summary];
  }
  return nil;
}

- (NSUInteger)summaryOffset {
  NSUInteger _offset = 0;
  if([component respondsToSelector:@selector(summaryOffset)]) {
    _offset = [component summaryOffset];
  }
  if(_offset == 0) {
    _offset = sessionHeaderOffset;
  }
  return _offset;
}

- (NSString *)task {
    return TASK;
}

- (NSString *) tempDirectory {
    return TEMPDIRECTORY;
}

-(void) throwError:(NSString *) errorDesc andBreak:(BOOL) shouldBreak {
   NSLog(@"%@",errorDesc);
	if(shouldBreak) {
        if([[NSApp delegate] respondsToSelector:@selector(throwError:)]) {
            [[NSApp delegate] performSelector:@selector(throwError:) withObject:errorDesc];
		} else {
            [NSApp presentError:[NSError errorWithDomain:[self className] code:101 userInfo:nil]];
        }
        // TODO: impement breaking procedure (tearDown,end,etc.)
	}
}

- (id)valueForRegistryKeyPath: (NSString *)aKeyPath {
  // lets just go ahead and ask our delegate
  return [delegate valueForRegistryKeyPath:aKeyPath];
}

@end

#pragma mark Preference Keys
NSString * const TKComponentTypeKey                     = @"TKComponentType";
NSString * const TKComponentNameKey                     = @"TKComponentName";
NSString * const TKComponentBundleNameKey               = @"TKComponentBundleName";
NSString * const TKComponentBundleIdentifierKey         = @"TKComponentBundleIdentifier";
NSString * const TKComponentRunKey                      = @"runs";
NSString * const TKComponentSummaryEndKey               = @"lastSummaryEndValue";
NSString * const TKComponentSummaryOffsetKey            = @"summaryOffsetValue";
NSString * const TKComponentSummaryStartKey             = @"lastSummaryStartValue";



#pragma mark Notification Names
NSString * const TKComponentWillBeginNotification       = @"TKComponentWillBegin";
NSString * const TKComponentDidBeginNotification        = @"TKComponentDidBegin";
NSString * const TKComponentDidFinishNotification       = @"TKComponentDidFinish";
