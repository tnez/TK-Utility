/***************************************************************
 
 TKComponentCocoaApp.H
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20101215 - tn
 
 ***************************************************************/


#import <Cocoa/Cocoa.h>


@interface TKComponentCocoaApp : NSObject {
  id                                          delegate;
  NSString                                    *appPath;
  NSString                                    *taskName;
  NSString                                    *inputDir;
  NSString                                    *outputDir;
  NSArray                                     *inputFiles;  
  NSArray                                     *outputFilesToIgnore;
  BOOL                                        shouldRenameOutputFiles;
  NSNumber                                    *pid;
}

@property (assign)            id              delegate;
@property (nonatomic, retain) NSString        *appPath;
@property (nonatomic, retain) NSString        *taskName;
@property (nonatomic, retain) NSString        *inputDir;
@property (nonatomic, retain) NSString        *outputDir;
@property (nonatomic, retain) NSArray         *inputFiles;
@property (nonatomic, retain) NSArray         *outputFilesToIgnore;
@property (readwrite)         BOOL            shouldRenameOutputFiles;

#pragma mark API
/**
 Launch the application and begin to poll for completion
 */
- (void)begin;

/**
 Instantiate using the parameters found in the given definition
 */
- (id)initWithDefinition: (NSDictionary *)definition;

/**
 Return yes if we have the values we need to attempt to launch app
 */
- (BOOL)isClearedToBegin;

/**
 Perform any clean up code nescesary - this will include moving 
 generated data files into our sessions data directory
 */
- (void)tearDown;

#pragma mark HELPER FUNCTIONS
/**
 Check that the application we recorded as our application of interest
 is the one that the workspace just terminated. If it is, then let our
 delegate know that we are done.
 */
- (void)checkIfApplicationIsDone: (NSNotification *)theNote;

/**
 Copy output file to target -- if a target name is given this method
 will attempt to rename the file upon copy
 If the copy fails the method logs the error and returns NO
 RETURN: YES upon success NO upon failure
 */
- (BOOL)copyOutputFile: (NSString *)filename asFileName: (NSString *)newName;

/**
 If the application that the workspace just did launch matches what
 we were expecting, then record critical info such as its process id
 */
- (void)getApplicationInfo: (NSNotification *)theNote;

/**
 Remove output file from output directory
 RETURN: YES upon success, NO upon failure
 NOTE: errors are logged w/in method
 */
- (BOOL)removeOutputFile: (NSString *)filename;

/**
 Return yes if this output file is found in our ignore list
 */
- (BOOL)shouldIgnoreOutputFile: (NSString *)pathToOutputFile;

@end

/**
 The following keys must be defined in the manifest file to facilitate
 the operation of the Cocoa Application
 */
#pragma mark PREFERENCE KEYS

/**
 The path to the application (same as you would launch from the Finder)
 */
extern NSString * const TKComponentCocoaAppPathKey;

/**
 The task name to use when renaming the datafile
 */
extern NSString * const TKComponentCocoaAppTaskNameKey;
/**
 The full path to the directory in which support files should be
 placed before the application is launched
 */
extern NSString * const TKComponentCocoaAppInputDirKey;

/**
 An array of full paths to each support file that should be placed in
 the application's input directory
 */
extern NSString * const TKComponentCocoaAppSupportFilesKey;

/**
 The output directory of the application, i.e. where is the datafile
 */
extern NSString * const TKComponentCocoaAppOutputDirKey;

/**
 Array of filenames that should not be moved from the output directory
 This may include crash recovery files or files that are 'don't cares'
 */
extern NSString * const TKComponentCocoaAppOutputFilesToIgnoreKey;

/**
 Indicate whether we should rename the output file using the task name
 and the conventions established by component controller.
 */
extern NSString * const TKComponentCocoaAppShouldRenameOutputFilesKey;
