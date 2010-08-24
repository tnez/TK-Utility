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
#import "TKComponentBundleDelegate.h"
#import "TKDelimitedFileParser.h"
#import "TKLibrary.h"
#import "TKLogging.h"
#import "TKSubject.h"
#import "TKTime.h"

#define BUNDLEIDENTIFIER [definition valueForKey:TKComponentBundleIdentifierKey]
#define DATADIRECTORY [[definition valueForKey:TKComponentDataDirectoryKey] stringByStandardizingPath]
#define DATAFILE [NSString stringWithFormat:@"%@_%@_%@_%@.@",STUDY,SUBJECT_ID,SHORTDATE,TASK,DATAFILE_EXTENSION]
#define DATAFILE_EXTENSION @"tsv"
#define DEFAULT_RUN_HEADER [NSString stringWithFormat:@"\nRun:\t%d\t%@\n",[self runCount],LONGDATE]
#define DEFAULT_SESSION_HEADER [NSString stringWithFormat:@"Task:\t%@\tSubject ID:\t%@\tSession#:\t%@\tDate:\t%@\n",TASK,SUBJECT_ID,SESSION,LONGDATE]
#define LONGDATE [[NSDate date] description]
#define SESSION [subject session]
#define SHORTDATE [self shortdate]
#define STUDY [subject study]
#define SUBJECT_ID [subject code]
#define TASK [definition valueForKey:TKComponentNameKey]
#define TEMPDIRECTORY [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"_TEMP"]
#define TEMPFILE [DATAFILE stringByAppendingString:@"~"]

@interface TKComponentController : NSObject <TKComponentBundleDelegate> {

    id                                          component;    
    id                                          delegate;
    NSDictionary                                *definition;
    TKLogging                                   *mainLog;
    TKLogging                                   *crashLog;
    TKSubject                                   *subject;
    NSWindow                                    *sessionWindow;
	TKTime                                      componentStartTime;
	TKTime                                      componentEndTime;    
}
@property (assign)              id              delegate;
@property (readonly)            NSDictionary    *definition;
@property (nonatomic, retain)   TKSubject       *subject;
@property (readonly)            TKTime          componentStartTime;
@property (readonly)            TKTime          componentEndTime;

/**
 This method actually begins the component, bringing the view up on the screen and starting the procedure.
 Should be overridden in subclass then passed to super.
 */
- (void)begin;

/**
 Sent when the loaded component bundle is complete - this should begin the tear down sequence
 Note: only sent by loadable bundle types
 */
- (void)componentDidFinish: (id)sender;

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
 Logs string to temporary file (also appends newline at end of string) - string should be sent in format desired for final data file
 */
- (void)logString: (NSString *)theString;

/**
 Validate the component without actually running - becuase the component is not run, this is only able to check setup errors
 Return: A string representation of all errors that occured in the component
 */
- (NSString *)preflightAndReturnErrorAsString;

/**
 Returns current session string
 */
- (NSString *)session;

/**
 Returns start time for component
 */
- (TKTime)startTime;

/**
 Returns current subject object for component
 */
- (TKSubject *)subject;

/**
 Returns current task name for component
 */
- (NSString *)task;

/**
 Run count for given file in directory. Returns 1 if file does not exist, otherwise looks for instances or previous runs and returns previous runs plus one.
 */
- (NSInteger)runCount;

/**
 Displays or logs error description based upon break parameter
 */
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;

@end

#pragma mark Preference Keys
/** Preference Keys */
extern NSString * const TKComponentTypeKey;
extern NSString * const TKComponentNameKey;
extern NSString * const TKComponentBundleIdentifierKey;
extern NSString * const TKComponentTaskNameKey;
extern NSString * const TKComponentDataDirectoryKey;

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
- (void)loadView: (NSView *)theView;
- (void)setDefinition: (NSDictionary *)newDefinition;
- (NSString *)shortdate;
@end


#pragma mark Protocols

/** Component Protocol - Component Bundles must implement this protocol */
@protocol TKComponentBundleLoading
/** Required Methods */
@required
/**
 Start the component - will receive this message from the component controller
 */
- (void)begin;
/**
 Return a string object representing all current errors in log form
 */
- (NSString *)errorLog;
/**
 Perform any and all error checking required by the component - return YES if passed
 */
- (BOOL)isclearedToBegin;
/**
 Accept assignment for the component definition
 */
- (void)setDefinition: (NSDictionary *)aDictionary;
/**
 Accept assignment for the component delegate - The component controller will assign itself as the delegate
 Note: The new delegate must adopt the TKComponentBundleDelegate protocol
 */
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate;
/**
 Perform any and all initialization required by component - this is where the nib file should be loaded
 */
- (void)setup;
/**
 Perform any and all finalization required by component
 */
- (void)tearDown;
/**
 Return the main view that should be presented to the subject
 */
- (NSView *)mainView;
/** Optional Methods */
@optional
/**
 Run header if something other than default is required
 */
- (NSString *)runHeader;
/**
 Session header if something other than default is required
 */
- (NSString *)sessionHeader;
/**
 Summary data if desired
 */
- (NSString *)summary;
@end

