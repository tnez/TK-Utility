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
#import "TKDelimitedFileParser.h"
#import "TKLibrary.h"
#import "TKLogging.h"
#import "TKSubject.h"
#import "TKTime.h"

#define BUNDLEIDENTIFIER [definition valueForKey:TKComponentBundleIdentifierKey]
#define DATADIRECTORY [[definition valueForKey:TKComponentDataDirectoryKey] stringByStandardizingPath]
#define DATAFILE [NSString stringWithFormat:@"%@_%@_%@_%@",STUDY,SUBJECT_ID,SHORTDATE,TASK]
#define LONGDATE [[NSDate date] description]
#define SESSION [subject session]
#define SHORTDATE [self shortdate]
#define STUDY [subject study]
#define SUBJECT_ID [subject code]
#define TASK [definition valueForKey:TKComponentNameKey]
#define NIB [definition valueForKey:TKComponentNibNameKey]

@interface TKComponentController : NSObject {

    /** Outlets To Be Connected To Bundles */
    IBOutlet NSDictionary       *definition;
    IBOutlet TKLogging          *mainLog;
    IBOutlet TKLogging          *crashLog;
    IBOutlet TKSubject          *subject;

    /** Outlets To Which I Connect */
	IBOutlet NSView             *view;
    NSWindow                    *sessionWindow;
    
    /** Values */
	TKTime                      componentStartTime;
	TKTime                      componentEndTime;    
}

/** Outlets (Advertised) */
@property (readonly)        IBOutlet NSDictionary   *definition;
@property (readonly)        IBOutlet TKLogging      *mainLog;
@property (readonly)        IBOutlet TKLogging      *crashLog;
@property (assign)          TKSubject               *subject;

/** Outlets (Managed) */
@property (assign)          IBOutlet NSView         *view;
@property (assign)          NSWindow                *sessionWindow;

/** Values */
@property (readonly)        TKTime                  componentStartTime;
@property (readonly)        TKTime                  componentEndTime;

/**
 This method actually begins the component, bringing the view up on the screen and starting the procedure.
 Should be overridden in subclass then passed to super.
 */
- (void)begin;

/**
 Ends the component, hiding view and releasing resources. Normally will not be called from outside the bundle except when early termination is required.
 Should be overridden in subclass then passed to super.
 */
- (void)end;

/**
 Preflight check. Called from outside bundle before sending begin message.
 Should be overridden in subclass then passed to super.Should be overriden in subclass then passed to super.
 */
- (BOOL)isClearedToBegin;

/**
 Way to load procedure bundle from the session. Normal instantiation will consist of this message, followed by a preflight check (isClearedToBegin) followed by the begin message.
 Will setup the definition dictionary for the component.
 This should not be overridden.
 */
+ (id)loadFromDefinition: (NSDictionary *)newDefinition;

/**
 Run count for given file in directory. Returns 1 if file does not exist, otherwise looks for instances or previous runs and returns previous runs plus one.
 */
- (NSInteger)runCountForFile: (NSString *)dataFileName inDirectory: (NSString *)dataDirectory;

@end

#pragma mark Preference Keys
/** Preference Keys */
extern NSString * const TKComponentTypeKey;
extern NSString * const TKComponentNameKey;
extern NSString * const TKComponentBundleIdentifierKey;
extern NSString * const TKComponentNibNameKey;
extern NSString * const TKComponentTaskNameKey;
extern NSString * const TKComponentDataDirectoryKey;
extern NSString * const TKComponentCrashRecoveryFileNameKey;

#pragma mark Enumerations
/** Enumerated Values */
enum {
    TKComponentTypeCocoaBundle              = 0,
    TKComponentTypeCocoaApplication         = 1,
    TKComponentTypeFutureBasicApplication   = 2
}; typedef NSInteger TKComponentType;   

#pragma mark Notifications
/** Notifications */
extern NSString * const TKComponentDidBeginNotification;
extern NSString * const TKComponentDidFinishNotification;


@interface TKComponentController(TKComponentControllerPrivate)

/**
 This method adds general header and run headers as needed. If a different header or run header is needed then override this method in the sub-class.
 */
-(void) addHeadersAsNeeded;

/**
 Load view of a Cocoa bundle. View must be connected to file's owner in the nib file of the component
 */
- (void)loadView;

- (void)setDefinition: (NSDictionary *)newDefinition;
- (NSString *)shortdate;
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;
@end
