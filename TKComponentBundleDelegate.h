#import "TKTime.h"
#import "TKSubject.h"


/** 
 TKComponentBundleDelegate: Denotes ability to perform delegate functions for 
 the a loadable cocoa bundle known as TKComponentBundle
 */

@protocol TKComponentBundleDelegate <NSObject>
/**
 Component should send this method to delegate when it has finished
 */
- (void)componentDidFinish: (id)sender;
/**
 Returns name of default temporary file as string
 */
- (NSString *)defaultTempFile;
/**
 Logs string to temporary file (also appends newline at end of string) - string
 should be sent in format desired for final data file
 */
- (void)logStringToDefaultTempFile: (NSString *)theString;
/**
 Logs string to given directory and file (also appends newline at end of string)
 */
- (void)logString: (NSString *)theString toDirectory: (NSString *)theDirectory
           toFile: (NSString *)theFile;
/**
 Return registry corresponding to given task ID... returns nil if not found.
 */
- (NSDictionary *)registryForTask: (NSInteger)taskID;
/**
 Return registry for the last completed task
 */
- (NSDictionary *)registryForLastTask;
/**
 Return registry for the task using the given offset value
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there
 */
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;
/**
 Return registry for run with offset for a given task ID
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there 
 */
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                                   forTask: (NSInteger)taskID;
/**
 Return registry for run with offset for a given task registry
 offset: -1 equals last task, less than -1 is offset from there, 1 equals
 first task, greter than 1 is offset from there
 */
- (NSDictionary *)registryForRunWithOffset: (NSInteger)offset
                           forTaskRegistry: (NSDictionary *)taskRegistry;
/**
 Return registry for last run of given task ID
*/
- (NSDictionary *)registryForLastRunForTask: (NSInteger)taskID;
/**
 Return registry for last run of given task registry
 */
- (NSDictionary *)registryForLastRunForTaskRegistry: (NSDictionary *)taskRegistry;
/**
 Returns the run count by evaluating the current data file
 */
- (NSInteger)runCount;
/**
 Current session value
 */
- (NSString *)session;
/**
 Set value for given key for the current run
 Return: YES upon success, NO upon failure
 */
- (BOOL)setValue: (id)newValue forRegistryKey: (NSString *)key;
/**
 Start time of the component
 */
- (TKTime)startTime;
/**
 Current subject object
 */
- (TKSubject *)subject;
/**
 Current task name
 */
- (NSString *)task;
/**
 Returns the full path of the temporary directory used for storing crash 
 recovery data and temporary raw data
 */
- (NSString *)tempDirectory;
/**
 Error handling method - when component encounters an error it should send this 
 message to delegate
 */
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;
@end
