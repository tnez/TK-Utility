#import "TKSubject.h"
#import "TKTime.h"

/** 
 TKComponentBundleDelegate: Denotes ability to perform delegate functions for the a loadable cocoa bundle known as TKComponentBundle
 */

@protocol TKComponentBundleDelegate
/**
 Component should send this method to delegate when it has finished
 */
- (void)componentDidFinish: (id)sender;
/**
 Log String to temporary file - string should be sent as it should appear in final data file
 */
- (void)logString: (NSString *)theString;
/**
 Returns the run count by evaluating the current data file
 */
- (NSInteger)runCount;
/**
 Current session value
 */
- (NSString *)session;
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
 Error handling method - when component encounters an error it should send this message to delegate
 */
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;
@end
