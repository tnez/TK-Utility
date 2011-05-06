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
#import <Foundation/Foundation.h>
#import "TKComponentBundleDelegate.h"
#import "TKDelimitedFileParser.h"
#import "TKLibrary.h"
#import "TKLogging.h"
#import "TKSubject.h"
#import "TKTime.h"
@class TKSession;

#define BUNDLE [NSBundle bundleWithPath:BUNDLEPATH]
#define BUNDLEIDENTIFIER [definition valueForKey:TKComponentBundleIdentifierKey]
#define BUNDLENAME [definition valueForKey:TKComponentBundleNameKey]
#define BUNDLEPATH [[[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:BUNDLENAME] stringByAppendingString:@".bundle"]
#define DATADIRECTORY [self dataDirectory]
#define DATAFILE [NSString stringWithFormat:@"%@_%@_%@_%@.%@",STUDY,SUBJECT_ID,SESSION,TASK,DATAFILE_EXTENSION]
#define DATAFILE_EXTENSION @"tsv"
#define DEFAULT_RUN_HEADER [NSString stringWithFormat:@"\nRun:\t%d\t%@\n",[self runCount],LONGDATE]
#define DEFAULT_SESSION_HEADER [NSString stringWithFormat:@"Task:\t%@\tSubject ID:\t%@\tSession#:\t%@\tDate:\t%@\n\n",TASK,SUBJECT_ID,SESSION,LONGDATE]
#define LONGDATE [[NSDate date] description]
#define PATH_TO_DATAFILE [DATADIRECTORY stringByAppendingPathComponent:DATAFILE]
#define SESSION [subject session]
#define SHORTDATE [self shortdate]
#define STUDY [subject study]
#define SUBJECT_ID [subject subject_id]
#define TASK [component taskName]
#define TEMPDIRECTORY [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"_TEMP"]
#define TEMPFILE [DATAFILE stringByAppendingString:@"~"]

@interface TKComponentController : NSObject <TKComponentBundleDelegate> {

  id                                          component;
  TKSession                                   *delegate;
  NSDictionary                                *definition;
  TKTimer                                     *timer;
  TKLogging                                   *mainLog;
  TKLogging                                   *crashLog;
  TKSubject                                   *subject;
  NSWindow                                    *sessionWindow;
  NSUInteger                                  sessionHeaderOffset;
  NSUInteger                                  lastSummaryEnd;
  TKTime                                      componentStartTime;
  TKTime                                      componentEndTime;
}

/**
   The Session object that will act as our delegate.
*/
@property (assign)              TKSession       *delegate;

/**
   The dictionary that defines our attributes.
*/
@property (readonly)            NSDictionary    *definition;

/**
   The timer object to which we can queue notifications.
*/
@property (assign)              TKTimer         *timer;

/**
   The log to which we can queue strings to write to files.
*/
@property (assign)              TKLogging       *mainLog;

/**
   A secondary log to which we can queue strings in parallel if needed
   for the recovery process.
*/
@property (assign)              TKLogging       *crashLog;

/**
   The subject object for our current session.
*/
@property (assign)              TKSubject       *subject;

/**
   The session window in which our veiws will be presented.
*/
@property (assign)              NSWindow        *sessionWindow;

/**
   Our recorded start time (for this component).
*/
@property (readonly)            TKTime          componentStartTime;

/**
   Our recorded end time (for this component).
*/
@property (readonly)            TKTime          componentEndTime;

/**
   Begin the component.

   This method actually begins the component, bringing the view up on
   the screen and starting the procedure. Should be overridden in
   subclass then passed to super. In the session a component instance
   is initialized, and then sent this message to start.
*/
- (void)begin;

/**
   The component instance did finish.

   This is sent (by bundles only, not with Cocoa Apps) when the bundle
   is complete. It is the responsibility of the bundle to send this
   message to its delegate when it has finished.
*/
- (void)componentDidFinish: (id)sender;

/**
   Reference to our delegate object. In most cases this will be the
   Session object.
*/
- (TKSession *)delegate;

/**
   The full path to our data directory to which we will be outputting
   data files upon the completion of our component.
*/
- (NSString *)dataDirectory;

/**
   The filename only of our default temporary file.
*/
- (NSString *) defaultTempFile;

/**
   Ends the component, hiding view and releasing resources. Normally
   will not be called from outside the bundle except when early
   termination is required. This will be called internally after
   receiving the component did finish message.
*/
- (void)end;

/**
   Is the component cleared to begin?

   May be called from outside the bundle before sending the begin
   message. This method is also implemented in the subclass where more
   specific checks can be done.
*/
- (BOOL)isClearedToBegin;

/**
   Load the bundle using the given dictionary as parameter
   definitions.

   This is the normal way that the session will load bundle instances.
   Normal instantiation will consist of this method, followed by a
   preflight check, followed by begin.

   @return An auto-released bundle instance as defined by the given
   dictionary.
*/
+ (id)loadFromDefinition: (NSDictionary *)newDefinition;

/**
   Convenience method to log a given string directly to the default
   temp file.
*/
- (void)logStringToDefaultTempFile: (NSString *)theString;

/**
   Log string to given directory and file (also appends newline at end
   of string).
*/
- (void)logString: (NSString *)theString
      toDirectory: (NSString *)theDirectory
           toFile: (NSString *)theFile;

/**
   Validate the component without actually running and return its
   error log.

   Because the component is not actually run, this method is incapable
   of detecting run time errors, and can only check that setup
   conditions are as required. The actual implementation of this must
   be defined in the subclass.

   @return The component's error log as string.
*/
- (NSString *)preflightAndReturnErrorAsString;

/**
   Return registry corresponding to given task ID... returns nil if
   not found.

   @param taskID The ID of the target task as defined in the session
   configuration file.
*/
- (NSDictionary *)registryForTask: (NSString *)taskID;

/**
   The registry for the last completed task.
*/
- (NSDictionary *)registryForLastTask;

/**
   Registry for the task using the given offset value.

   @param offset How far offset is the target task from the current
   task? -1 represents the last completed task, -n represents the task
   completed n tasks-ago. 1 equals the first task, n represents nth
   completed task starting at the beginning. 0 represents the current
   task.
*/
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;

/**
   Registry for run with offset for a given task ID.

   @param offset How far offset is the target task from the current
   task? -1 represents the last completed task, -n represents the task
   completed n tasks-ago. 1 equals the first task, n represents nth
   completed task starting at the beginning. 0 represents the current
   task.

   @param taskID The ID of the target task as defined in the session
   configuration file.
*/
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                                   forTask: (NSString *)taskID;

/**
   Registry for run with offset for a given task registry.

   @param offset How far offset is the target task from the current
   task? -1 represents the last completed task, -n represents the task
   completed n tasks-ago. 1 equals the first task, n represents nth
   completed task starting at the beginning. 0 represents the current
   task.

   @param taskRegistry An existing task registry from which to query run.
*/
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                           forTaskRegistry: (NSDictionary *)taskRegistry;

/**
   Registry for last run of given task ID.

   @param taskID The ID of the target task as defined in the session
   configuration file.
*/
- (NSDictionary *)registryForLastRunForTask: (NSString *)taskID;

/**
   Registry for last run of a given registry.

   @param taskRegistry The registry with which to query the last run.
*/
- (NSDictionary *)registryForLastRunForTaskRegistry: (NSDictionary *)taskRegistry;

/**
   Run count of the current component.

   This method determines the run count by querying its own registry
   and counting the number of run registries in its run collection.

*/
- (NSInteger)runCount;

/**
   Run header for the component instance. This method can be overriden
   in the subclass to provide a custom run header, otherwise the
   default run header will be used.
*/
- (NSString *)runHeader;

/**
   Session identifier as string.
*/
- (NSString *)session;

/**
   Session header for the component instance. This method can be
   overriden in the subclass to provide a custom session header,
   otherwise the default session header will be used.
*/
- (NSString *)sessionHeader;

/**
   Set value for given global key for the current task

   @param newValue The new value you wish to store.

   @param key The key with which you would like to associate the new
   value.
*/
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key;

/**
   Set value for given key for current run of current task

   @param newValue The new value you wish to store.

   @param key The key with which you would like to associate the new
   value.
*/
- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key;

/**
   Start time of the component as a TKTime marker.
*/
- (TKTime)startTime;

/**
   The current subject object.
*/
- (TKSubject *)subject;

/**
   The summary entry to be placed into the log file if desired. If
   this method is not implemented in the subclass, the component will
   not output a summary entry (this is considered the default
   behavior).
*/
- (NSString *)summary;

/**
   The offset of the summary from the beginning of the logfile in
   bytes.

   This method is required if a summary entry is implemented by the
   subclass so that we know where in the file to write the
   summary. This sounds scary, but included in the bundle template,
   albeit commented out, are the two most common implementations, an
   overwritting summary, and an appending summary, that can simply be
   uncommented in order to implement one or the other.
*/
- (NSUInteger)summaryOffset;

/**
   Current task name for component as string.
*/
- (NSString *)task;

/**
   Full path to temporary directory as string.
*/
- (NSString *)tempDirectory;

/**
   Error handling method - when component encounters an error it
   should send this message to delegate.

   Currently this method is not hanlded in the delegate, but if we
   pass all run-time errors here, it gives us one convenient place to
   handle errors and error notifications.
*/
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;

/**
   Value for registry key path (this is nescesary for bundles to
   effectively share information through the registry)

   @param aKeyPath The key path you wish to query, from the
   root of the registry file.

   @return The object associated with the given key path, or
   nil, if the key path given could not be located in the registry.

*/
- (id)valueForRegistryKeyPath: (NSString *)aKeyPath;

@end

#pragma mark Preference Keys
/** Preference Keys */
extern NSString * const TKComponentTypeKey;
extern NSString * const TKComponentNameKey;
extern NSString * const TKComponentBundleNameKey;
extern NSString * const TKComponentBundleIdentifierKey;
extern NSString * const TKComponentRunKey;
extern NSString * const TKComponentSummaryEndKey;
extern NSString * const TKComponentSummaryOffsetKey;
extern NSString * const TKComponentSummaryStartKey;



#pragma mark Enumerations
/** Enumerated Values */
enum {
  TKComponentTypeCocoaBundle              = 0,
  TKComponentTypeCocoaApplication         = 1,
  TKComponentTypeFutureBasicApplication   = 2
}; typedef NSInteger TKComponentType;

#pragma mark Notifications
/** Notifications */
extern NSString * const TKComponentWillBeginNotification;
extern NSString * const TKComponentDidBeginNotification;
extern NSString * const TKComponentDidFinishNotification;


@interface TKComponentController(TKComponentControllerPrivate)
- (void)loadView: (NSView *)theView;
- (void)setDefinition: (NSDictionary *)newDefinition;
- (NSString *)shortdate;
@end


#pragma mark Protocols

/** Component Protocol - Component Bundles must implement this protocol */
@protocol TKComponentBundleLoading <NSObject>
/** Required Methods */
@required
/**
   Start the component - will receive this message from the component controller
*/
- (void)begin;
/**
   Return a string representing the data directory for the component
*/
- (NSString *)dataDirectory;
/**
   Return a string object representing all current errors in log form
*/
- (NSString *)errorLog;
/**
   Perform any and all error checking required by the component - return YES if passed
*/
- (BOOL)isClearedToBegin;
/**
   Returns the file name containing the raw data that will be appended to the data file
*/
- (NSString *)rawDataFile;
/**
   Perform actions required to recover from crash using the given raw data passed as string
*/
- (void)recover;
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
   Perform any and all initialization required by component - load any nib files and perform all required initialization
*/
- (void)setup;
/**
   Return YES if component should perform recovery actions
*/
- (BOOL) shouldRecover;
/**
   Return the name for the current task
*/
- (NSString *)taskName;
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

