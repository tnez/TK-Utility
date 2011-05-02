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
@class TKComponentController;
@class TKFileMoveQueue;


@interface TKComponentCocoaApp : NSObject {
  TKComponentController                       *delegate;
  NSString                                    *appPath;
  NSString                                    *taskName;
  NSString                                    *dataDir;
  NSString                                    *inputDir;
  NSString                                    *outputDir;
  NSArray                                     *inputFiles;  
  NSArray                                     *outputFilesToCopy;
  NSArray                                     *outputFileNamesAppendage;
  BOOL                                        shouldRenameOutputFiles;
  NSNumber                                    *pid;
  TKFileMoveQueue                             *moveQueue;
}

/**
   Delegate of the abstract Cocoa App. This will most likely be the
   session.

*/
@property (assign)    TKComponentController   *delegate;

/**
   Full-path to the application on disk.

*/
@property (nonatomic, retain) NSString        *appPath;

/**
   Task name of the component.

*/
@property (nonatomic, retain) NSString        *taskName;

/**
   Data directory if required.

*/
@property (nonatomic, retain) NSString        *dataDir;

/**
   The directory where required input files (dependencies of the Cocoa
   App) should be placed.

*/
@property (nonatomic, retain) NSString        *inputDir;

/**
   The directory where the Cocoa App puts data files, etc.

*/
@property (nonatomic, retain) NSString        *outputDir;

/**
   List of file dependencies for the Cocoa App.

*/
@property (nonatomic, retain) NSArray         *inputFiles;

/**
   List of files that should be copied from the Cocoa App's output
   directory, to our defined data directory.

*/
@property (nonatomic, retain) NSArray         *outputFilesToCopy;

/**
   List of extensions that should be used when moving output files to
   data directory. This list should be ordered relative to
   'outputFilesToCopy'.

*/
@property (nonatomic, retain) NSArray         *outputFileNamesAppendage;

/**
   Should the Cocoa App use renaming rules when copying files from
   output dir to data dir?

*/
@property (readwrite)         BOOL            shouldRenameOutputFiles;

/**
   Special purpose queue designed to help queue move files.

*/
@property (assign)            TKFileMoveQueue *moveQueue;

#pragma mark API

/**
   Launch the application and begin to poll for completion.

*/
- (void)begin;

/**
   Instantiate using the parameters found in the given definition @param
   definition The dictionary generated from the session configuration
   file for this Cocoa App component.

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
   Clean input directory (remove any support that we created)
*/
- (BOOL)cleanInputDirectory;

/**
   Copy output files - loop through all the output files and handle
   their copying according to shouldRenameOutputFile and
   outputFilesToCopy parameters
   
   @return YES if all files were copied successfully - otherwise NO

*/
- (BOOL)queueOutputFiles;

/**
   Copy specified support files into our support directory. Creates
   support directory if does not already exist and logs any errors
   encountered during copy process.

  @return YES upon success NO upon failure

*/
- (BOOL)copySupportFiles;

/**
   Create the specified support directory if it does not already
   exists.

*/
- (void)createSupportDirectoryIfNeeded;

/**
   If the application that the workspace just did launch matches what
   we were expecting, then record critical info such as its process
   id.

*/
- (void)getApplicationInfo: (NSNotification *)theNote;

@end

/**
   The following keys must be defined in the manifest file to facilitate
   the operation of the Cocoa Application
*/
#pragma mark PREFERENCE KEYS

/**
   The path to the application (same as you would launch from the Finder) -
   If relative paths are being used this path is appended to the session
   application bundle
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
   An array of paths to each support file that should be placed in
   the application's input directory. The individual paths can be relative to the
   session application bundle or absolute.
*/
extern NSString * const TKComponentCocoaAppSupportFilesKey;

/**
   Directory containing output (data) files generated in the course of the
   program
*/
extern NSString * const TKComponentCocoaAppOutputDirKey;

/**
   Array of filenames that should be moved from the output directory to the
   data directory. Anything else will be ignored.
*/
extern NSString * const TKComponentCocoaAppOutputFilesToCopyKey;

/**
   (Optional) Array of target filenames that should be used in naming output
   files. List should be in same order as FilesToCopy (i.e. index zero file
   to copy is appended with index zero appendage)
*/
extern NSString * const TKComponentCocoaAppOutputFileNamesAppendageKey;

/**
   Indicate whether we should rename the output file using the task name
   and the conventions established by component controller.
*/
extern NSString * const TKComponentCocoaAppShouldRenameOutputFilesKey;

/**
   Indicate whether we should interpret all paths (with the exception of the 
   application and support files) as relative to application path. If yes, any
   given paths will be appended to the application path and then expanded.
   Relative paths like: ../../DATA (DATA folder two levels up from the 
   application path).
*/
extern NSString * const TKComponentCocoaAppShouldUseRelativePathsKey;
