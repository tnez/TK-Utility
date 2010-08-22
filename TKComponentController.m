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
@synthesize delegate,dataDirectory,view,sessionWindow,subject,componentStartTime,componentEndTime;

-(void) begin {
    switch ([definition valueForKey:TKComponentTypeKey]) {
        case TKComponentBundleType:
            // load nib resource
            [NSBundle loadNibNamed:[definition valueForKey:TKComponentViewNibNameKey] owner:self];
            [self loadView];
            break;
        case TKComponentCocoaAppType:
            // TODO: load cocoa application
            [self throwError:@"Cannot load CoCoa applications (support is coming soon)" andBreak:YES];
            break;
        case TKComponentFutureBasicAppType:
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
    [dataDirectory release];
    [definition release];
	[super dealloc];
}

-(void) end {
    componentEndTime = current_time_marker();
    [view exitFullScreenModeWithOptions:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKComponentDidFinishNotification object:self];
}

-(BOOL) isClearedToBegin {
    BOOL exists, isDirectory;
    exists = [[NSFileManager defaultManager] fileExistsAtPath:dataDirectory isDirectory:&isDirectory];
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
        [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:&creationError];
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

- (void)setDefinition: (NSDictionary *)newDefinition {
    [definition release];
    definition = [[NSDictionary alloc] initWithDictionary:newDefinition];
}

-(void) throwError:(NSString *) errorDesc andBreak:(BOOL) shouldBreak {
   NSLog(@"%@: %@",[self class],errorDesc);
	if(shouldBreak) {
        if([[NSApp delegate] respondsToSelector:@selector(presentError:)]) {
            [[NSApp delegate] presentError:errorDesc];
		} else {
            [NSApp presentError:[NSError errorWithDomain:[self class] code:101 userInfo:nil]];
	}
}

@end

#pragma mark Preference Keys
NSString * const TKComponentTypeKey = @"TKComponentType";
NSString * const TKComponentNameKey = @"TKComponentName";
NSString * const TKComponentBundleIdentifierKey = @"TKComponentBundleIdentifier";
NSString * const TKComponentViewNibNameKey = @"TKComponentViewNibName";
NSString * const TKComponentPreferencesNibNameKey = @"TKComponentPreferencesNibName";
NSString * const TKComponentPreferencesFileNameKey = @"TKComponentPreferencesFileName";
NSString * const TKComponentPreferencesFileTypeKey = @"TKComponentPreferencesFileType";

