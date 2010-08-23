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
@synthesize definition,mainLog,crashLog,subject,view,sessionWindow,componentStartTime,componentEndTime;

-(void) addHeadersAsNeeded {
    NSInteger runCount = [self runCountForFile:DATAFILE inDirectory:DATADIRECTORY];
    if(runCount == 1) {
        // write general header
        NSString *generalHeader=[[NSString stringWithFormat:@"Task:\t%@\tSubject ID:\t%@\tSession#:\t%@\tDate:\t%@",
                                  TASK,SUBJECT_ID,SESSION,LONGDATE]retain];
        [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[generalHeader autorelease] overWriteOnFirstWrite:YES];
    }
    // write run header
    NSString *runHeader=[[NSString stringWithFormat:@"Run:\t%d\t%@",runCount,LONGDATE] retain];
    [mainLog writeToDirectory:DATADIRECTORY file:DATAFILE contentsOfString:[runHeader autorelease] overWriteOnFirstWrite:NO];
}

-(void) begin {
    
    // grab component start time
    componentStartTime = current_time_marker();
    
    // begin component according to component type
    switch ([[definition valueForKey:TKComponentTypeKey] integerValue]) { 

        case TKComponentTypeCocoaBundle:
            // if the bundle loads
            if([[NSBundle bundleWithIdentifier:BUNDLEIDENTIFIER] load]) { 
                [self addHeadersAsNeeded];
                [NSBundle loadNibNamed:NIB owner:self];
                [self loadView];
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

-(void) dealloc {
    [definition release];
	[super dealloc];
}

-(void) end {
    componentEndTime = current_time_marker();
    [view exitFullScreenModeWithOptions:nil];
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
                
+(id) loadFromDefinition:(NSDictionary *) newDefinition {
    // create new instance
    TKComponentController *newComponent = [[TKComponentController alloc] init];
    // configure new component
    [newComponent setDefinition:newDefinition];
    return [newComponent autorelease];
}

-(void) loadView {
    [[TKLibrary sharedLibrary] centerView:view inWindow:sessionWindow];
}

-(NSInteger) runCountForFile: (NSString *)file inDirectory: (NSString *)directory {
    NSInteger count = 0;
    TKDelimitedFileParser *parser = [[TKDelimitedFileParser alloc] initParserWithFile:[directory stringByAppendingPathComponent:file] usingEncoding:NSUTF8StringEncoding withRecordDelimiter:@"\n" withFieldDelimiter:@"\t"];
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

-(void) throwError:(NSString *) errorDesc andBreak:(BOOL) shouldBreak {
   NSLog(@"%@: %@",[self class],errorDesc);
	if(shouldBreak) {
        if([[NSApp delegate] respondsToSelector:@selector(throwError:)]) {
            [[NSApp delegate] performSelector:@selector(throwError:) withObject:errorDesc];
		} else {
            [NSApp presentError:[NSError errorWithDomain:[self className] code:101 userInfo:nil]];
        }
	}
}

@end

#pragma mark Preference Keys
NSString * const TKComponentTypeKey                     = @"TKComponentType";
NSString * const TKComponentNameKey                     = @"TKComponentName";
NSString * const TKComponentBundleIdentifierKey         = @"TKComponentBundleIdentifier";
NSString * const TKComponentNibNameKey                  = @"TKComponentNibName";
NSString * const TKComponentTaskNameKey                 = @"TKComponentTaskName";
NSString * const TKComponentDataDirectoryKey            = @"TKComponentDataDirectory";
NSString * const TKComponentCrashRecoveryFileNameKey    = @"TKComponentCrashRecoveryFileNameKey";

#pragma mark Notification Names
NSString * const TKComponentDidBeginNotification        = @"TKComponentDidBegin";
NSString * const TKComponentDidFinishNotification       = @"TKComponentDidFinish";
