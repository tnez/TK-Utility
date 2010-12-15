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
        // append header and summary info to datafile
        [[component mainView] removeFromSuperview];        // remove the components view from window
        if([self runCount] == 1) {
            if([component respondsToSelector:@selector(sessionHeader)]) {
                [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[component sessionHeader] overWriteOnFirstWrite:NO];
            } else { // use default session header
                [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:DEFAULT_SESSION_HEADER overWriteOnFirstWrite:NO];
            }
        } else {}
        if([component respondsToSelector:@selector(runHeader)]) { // custom run header
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[component runHeader] overWriteOnFirstWrite:NO];
        } else { // use default run heaer
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:DEFAULT_RUN_HEADER overWriteOnFirstWrite:NO];
        }
        if([component respondsToSelector:@selector(summary)]) {
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[component summary] overWriteOnFirstWrite:NO];
        } else {}
        // wait for log queue to clear
        while([TKLogging unwrittenItemCount] > 0) {
            NSLog(@"TKComponentController waiting for log queue to clear before finalizing data file");
        }
        // transfer raw data from temp file to datafile
        NSString *rawData = [NSString stringWithContentsOfFile:[TEMPDIRECTORY stringByAppendingPathComponent:[component rawDataFile]]];
        [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:rawData overWriteOnFirstWrite:NO];
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

-(void) dealloc {
    [definition release];
	[super dealloc];
}

- (NSString *)defaultTempFile {
    return TEMPFILE;
}

-(void) end {
    componentEndTime = current_time_marker();
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentDidFinishNotification object:self];
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

- (NSInteger) runCount {
    NSInteger count = 0;
    TKDelimitedFileParser *parser = [[TKDelimitedFileParser alloc] initParserWithFile:[DATADIRECTORY stringByAppendingPathComponent:DATAFILE]
                                                                        usingEncoding:NSUTF8StringEncoding
                                                                  withRecordDelimiter:@"\n"
                                                                   withFieldDelimiter:@"\t"];
    if(parser) {    // if the file was parsed
        for(id record in [parser records]) {
            if([[record objectAtIndex:0] isEqualToString:@"Run:"]) {
                count++;
            }
        }
        [parser release];
    }
    return count + 1;
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

- (TKTime)startTime {
    return componentStartTime;
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

@end

#pragma mark Preference Keys
NSString * const TKComponentTypeKey                     = @"TKComponentType";
NSString * const TKComponentNameKey                     = @"TKComponentName";
NSString * const TKComponentBundleNameKey               = @"TKComponentBundleName";
NSString * const TKComponentBundleIdentifierKey         = @"TKComponentBundleIdentifier";



#pragma mark Notification Names
NSString * const TKComponentWillBeginNotification       = @"TKComponentWillBegin";
NSString * const TKComponentDidBeginNotification        = @"TKComponentDidBegin";
NSString * const TKComponentDidFinishNotification       = @"TKComponentDidFinish";
