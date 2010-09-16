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

@implementation TKComponentController
@synthesize delegate,definition,subject,sessionWindow,componentStartTime,componentEndTime;

-(void) begin {

    if(![self isClearedToBegin]) { return; }
    
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
                if([component isClearedToBegin]) {      // -  if component is good to go...
                    [component setDelegate:self];       // 3) register self as delegate
                    [self loadView:[delegate mainView]];// 4) pull up the view in session window
                    [component begin];                  // 5) begin component
                } else {
                    [self throwError:[component errorLog] andBreak:YES];
                }
            } else { // the bundle did not load
                [self throwError:@"Could not load specified bundle" andBreak:YES];
            }
            break;

        case TKComponentTypeCocoaApplication:
            // TODO: load cocoa application
            [self throwError:@"Cannot load CoCoa applications (support is coming soon)" andBreak:YES];
            break;

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
    if([sender conformsToProtocol:@protocol(TKComponentBundleLoading)]) {
        // append header and summary info to datafile
        [[sender mainView] removeFromSuperview];        // remove the components view from window
        [sender tearDown];                              // let the component finalize
        if([self runCount] == 1) {
            if([sender respondsToSelector:@selector(sessionHeader)]) {
                [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[sender sessionHeader] overWriteOnFirstWrite:NO];
            } else { // use default session header
                [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:DEFAULT_SESSION_HEADER overWriteOnFirstWrite:NO];
            }
        } else {}
        if([sender respondsToSelector:@selector(runHeader)]) { // custom run header
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[sender runHeader] overWriteOnFirstWrite:NO];
        } else { // use default run heaer
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:DEFAULT_RUN_HEADER overWriteOnFirstWrite:NO];
        }
        if([sender respondsToSelector:@selector(summary)]) {
            [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[sender summary] overWriteOnFirstWrite:NO];
        } else {}
        // wait for log queue to clear
        while([TKLogging unwrittenItemCount] > 0) {
            NSLog(@"TKComponentController waiting for log queue to clear before finalizing data file");
        }
        // transfer raw data from temp file to datafile
        NSString *rawData = [NSString stringWithContentsOfFile:[TEMPDIRECTORY stringByAppendingPathComponent:[sender rawDataFile]]];
        [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:rawData overWriteOnFirstWrite:NO];
        [rawData release];
        // clean up sender -- it is the sender's responsibility to remove it's temporary files (raw data file included)
        [sender tearDown];
        [sender release]; 
    } else {
        // this is where anything would go if an application component is sending this message
    }
}
    
-(void) dealloc {
    [definition release];
	[super dealloc];
}

- (NSString *)defaultTempFile {
    return TEMPFILE;
}

-(void) end {
    component = nil;
    componentEndTime = current_time_marker();
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentDidFinishNotification object:self];
}

- (BOOL)isClearedToBegin {
    BOOL exists, isDirectory;
    exists = [[NSFileManager defaultManager] fileExistsAtPath:DATADIRECTORY isDirectory:&isDirectory];
    if(exists) {
        if(isDirectory) {
            return YES; // expected case (file exists and is directory)
        } else {
            [self throwError:@"Data Directory is not valid" andBreak:YES];
            return NO;
        }
    } else {
        // try to create directory
        NSError *creationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:DATADIRECTORY withIntermediateDirectories:YES attributes:nil error:&creationError];
        if(creationError) { // there was an error creating the directory
            [self throwError:@"Could not create Data Directory" andBreak:YES];
            return NO;
        } else { // there was no error creating the directory
            return YES;
        }
    }
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
                if([component isClearedToBegin]) {      // -  if component is good to go...
                    return @"Bundle Successfully Loaded (No Errors Reported)\n";
                } else {
                    return [component errorLog];
                }
            } else { // component does not conform to required protocol
                return @"Bundle does not conform to required protocol\n";
            }
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
	[formatter setDateFormat:@"MM-dd-yy"];
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
NSString * const TKComponentTaskNameKey                 = @"TKComponentTaskName";
NSString * const TKComponentDataDirectoryKey            = @"TKComponentDataDirectory";

#pragma mark Notification Names
NSString * const TKComponentDidBeginNotification        = @"TKComponentDidBegin";
NSString * const TKComponentDidFinishNotification       = @"TKComponentDidFinish";
