#import "TKTime.h"
#import "TKSubject.h"


/** 
    TKComponentBundleDelegate: Denotes ability to perform delegate functions for 
    the a loadable cocoa bundle known as TKComponentBundle
*/

@protocol TKComponentBundleDelegate <NSObject>
/** 
    The component bunle did finish

    @param sender The component that has finished.

    The component bundle should send this message to its delegate when
    it has finished operation. After this, the tearDown message will
    be sent to the component by this delegate.

  */
- (void)componentDidFinish: (id)sender;

/**
   Returns name of default temporary file as string

*/
- (NSString *)defaultTempFile;

/**
   Logs string to temporary file (also appends newline at end of
   string) - string should be sent in format desired for final data
   file.

   @param theString The string to be logged to the default temp file.

*/
- (void)logStringToDefaultTempFile: (NSString *)theString;

/**
   Logs string to given directory and file (also appends newline at
   end of string).

   @param theString String to be logged
   @param theDirectory Directory of the target file.
   @param theFile Filename of the target file.

*/
- (void)logString: (NSString *)theString toDirectory: (NSString *)theDirectory
           toFile: (NSString *)theFile;

/**
   Return registry corresponding to given task ID... returns nil if
   not found.

   @param taskID The ID of the target task as defined in the session
   configuration file.

*/
- (NSDictionary *)registryForTask: (NSString *)taskID;

/**
   Return registry for the last completed task

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
   Session identifier as string.

*/
- (NSString *)session;

/**
   The window with which the session runs components.

*/
- (NSWindow *)sessionWindow;

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
   Current task name
*/
- (NSString *)task;

/**
   The full path of the temporary directory used for storing crash
   recovery data and temporary raw data.

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

@end
