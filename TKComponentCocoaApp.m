//
//  TKComponentCocoaApp.m
//  TKUtility
//
//  Created by tnesland on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKComponentCocoaApp.h"
#import "TKComponentController.h"
#import "TKSession.h"
#import "TKFileMoveQueue.h"


@implementation TKComponentCocoaApp
@synthesize delegate,appPath,taskName,dataDir,inputDir,outputDir,inputFiles,
outputFilesToCopy,outputFileNamesAppendage,shouldRenameOutputFiles,moveQueue;

/**
 Launch the application
 */
- (void)begin {
  // grab notification center for shared workspace
  NSNotificationCenter *postOffice = [[NSWorkspace sharedWorkspace]
                                      notificationCenter];
  // register for useful notifications
  [postOffice addObserver:self
                 selector:@selector(getApplicationInfo:)
                     name:NSWorkspaceDidLaunchApplicationNotification
                   object:nil];
  [postOffice addObserver:self
                 selector:@selector(checkIfApplicationIsDone:)
                     name:NSWorkspaceDidTerminateApplicationNotification
                   object:nil];
  // launch the application
  if(![[NSWorkspace sharedWorkspace] launchApplication:appPath]) {
    // ...the application failed to launch...
    // log issue
    ELog(@"The Cocoa Application: %@ failed to launch",appPath);
    // notify the delegate that we have finished
    [delegate componentDidFinish:self];
  }
  // else... application did launch
}

/**
 Check that the application we recorded as our application of interest
 is the one that the workspace just terminated. If it is, then let our
 delegate know that we are done.
 */
- (void)checkIfApplicationIsDone: (NSNotification *)theNote {
  // if the application that just finished, matches our recorded pid...
  if([[[theNote userInfo] valueForKey:@"NSApplicationProcessIdentifier"]
      isEqualToNumber:pid]) {
    // ...this is our latched app...we are done
    [delegate componentDidFinish:self];
  } else { // else, this is not the droid we are looking for
    DLog(@"Waiting for pid:%d to end, not pid:%d",[pid integerValue],
          [[[theNote userInfo]
            valueForKey:@"NSApplicationProcessIdentifier"] integerValue]);
  }
}

/**
 Clean input directory (remove any support that we created)
 */
- (BOOL)cleanInputDirectory {
  NSInteger errorCount = 0;  
  // for each file in our input list
  for(NSString *filePath in inputFiles) {
    // get the filename
    NSString *fileName = [filePath lastPathComponent];
    // attempt to remove the file from the apps input dir
    // and keep track of errors
    NSError *removalError = nil;

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[inputDir stringByAppendingPathComponent:fileName]
                   error:&removalError];
    // if there was an error...
    if(removalError) {
      // log the error
      ELog(@"There was an error removing the support file: %@... %@",
            fileName,[removalError localizedDescription]);
      // inrement the error counter
      errorCount++;
    } // end of error handling
  } // end of file processing loop
  // return success YES|NO
  return !(errorCount>0);
}

/**
 Add any file listed in the output files to the moveQueue
 Rerturn YES upon success
 */
- (BOOL)queueOutputFiles {
  NSUInteger errorCount = 0;
  @try {
    // incrementer for looping
    for(NSUInteger i=0; i<[outputFilesToCopy count]; i++) {
      // ...if we are renaming the files
      if(shouldRenameOutputFiles) {
        // ... add output,input
        if(![moveQueue queueInputFile:[outputDir stringByAppendingPathComponent:
                                       [outputFilesToCopy objectAtIndex:i]]
                        forOutputFile:[dataDir stringByAppendingPathComponent:
                                       [NSString stringWithFormat:@"%@_%@_%@_%@.%@",
                                        [[delegate subject] study],
                                        [[delegate subject] subject_id],
                                        [[delegate subject] session],
                                        [outputFileNamesAppendage objectAtIndex:i++],
                                        @"tsv"]]]) {
          // there was some error
          ELog(@"Could not add %@ to the move queue",
               [outputFilesToCopy objectAtIndex:i]);
          errorCount++;
        }
      } else { // not renaming
        // ... add input output
        if(![moveQueue queueInputFile:[outputDir stringByAppendingPathComponent:
                                       [outputFilesToCopy objectAtIndex:i]]
                        forOutputFile:[dataDir stringByAppendingPathComponent:
                                       [outputFilesToCopy objectAtIndex:i]]]) {
          // there was some error
          ELog(@"Could not add %@ to the move queue",
               [outputFilesToCopy objectAtIndex:i]);
          errorCount++;
        }
      }
    }
  }
  @catch (NSException *e) {
    ELog(@"%@",e);
  }
  return errorCount==0;
}

/**
 Copy specified support files into our support directory
 - creates support directory if does not already exist
 - logs any errors encountered during copy process
 RETURN: YES upon success NO upon failure
 */
- (BOOL)copySupportFiles {
  // our local error flag
  BOOL hadError = NO;
  // create support directory if needed
  [self createSupportDirectoryIfNeeded];
  // copy support files into input directory
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *copyError = nil;
  for(NSString *file in inputFiles) {
    NSString *nameComponent = [[file lastPathComponent] retain];
    // if the file already exists at path...
    if([fm fileExistsAtPath:
        [inputDir stringByAppendingPathComponent:nameComponent]]) {
      // ...attempt to remove the old file
      NSError *deleteError = nil;
      [fm removeItemAtPath:
       [inputDir stringByAppendingPathComponent:nameComponent]
                     error:&deleteError];
      // if there was an error deleting the file...
      if(deleteError) {
        // ...log the error
        ELog(@"Error deleting the old support file: %@... %@",
              [file stringByStandardizingPath],
              [deleteError localizedDescription]);
      } // end delete error handling
    }   // end attempt delete old support files
    [fm copyItemAtPath:[file stringByStandardizingPath]
                toPath:[inputDir stringByAppendingPathComponent:nameComponent]
                 error:&copyError];
    // if there was an error copying the file...
    if(copyError) {
      // log the error
      ELog(@"Error copying: %@ to: %@... %@",
            [file stringByStandardizingPath],
            inputDir,[copyError localizedDescription]);
      // note error
      hadError = YES;
    } // end of handle copy error
    [nameComponent release];
  }   // end of copy input file to input dir
  return !hadError;
}

/**
 If the specified support directory does not exist, create
 */
- (void)createSupportDirectoryIfNeeded {
  // if definition specifies support directory...
  if(inputDir) {
    NSFileManager *fm = [NSFileManager defaultManager];
    // if said input directory does not exist...
    BOOL isDirectory = NO;
    if(!([fm fileExistsAtPath:inputDir isDirectory:&isDirectory]
         && isDirectory)) {
      // ...create the directory
      [fm createDirectoryAtPath:inputDir attributes:nil];
    }
  }
}

- (void)dealloc {
  // remove our notifications
  [[[NSWorkspace sharedWorkspace] notificationCenter]
   removeObserver:self];
  // release our memory
  [appPath release];
  [taskName release];
  [inputDir release];
  [outputDir release];
  [dataDir release];
  [inputFiles release];
  [outputFilesToCopy release];
  [pid release];
  // obligatory super call
  [super dealloc];
}
  
/**
 If the application that the workspace just did launch matches what
 we were expecting, then record critical info such as its process id
 */
- (void)getApplicationInfo: (NSNotification *)theNote {
  // if the full path of the application matches our app path
  if([[[theNote userInfo] valueForKey:@"NSApplicationPath"]
      isEqualToString:appPath]) {
    // then this is what we are looking for...
    // lets grab the info we need
    pid = [[[theNote userInfo]
            valueForKey:@"NSApplicationProcessIdentifier"] retain];
    NSLog(@"Cocoa App Component has latched on to %d",
          [pid integerValue]);
  } else { // this is not the droid we are looking for
    NSLog(@"Cocoa App has started, but no match... app:%@ pid:%d",
          [[theNote userInfo] valueForKey:@"NSApplicationPath"],
          [[[theNote userInfo] valueForKey:@"NSApplicationProcessIdentifier"]
           integerValue]);
  }
}

/**
 Instantiate using the parameters found in the given definition
 */
- (id)initWithDefinition: (NSDictionary *)definition {
  if(self=[super init]) {
    // taskName
    [self setTaskName:
     [definition valueForKey:TKComponentCocoaAppTaskNameKey]];
    // dataDir
    [self setDataDir:[delegate dataDirectory]];
    // inputFiles
    [self setInputFiles:
     [definition valueForKey:TKComponentCocoaAppSupportFilesKey]];
    // outputFilesToCopy
    [self setOutputFilesToCopy:
     [definition valueForKey:TKComponentCocoaAppOutputFilesToCopyKey]];
    // outputFileNamesAppendage
    [self setOutputFileNamesAppendage:
     [definition valueForKey:TKComponentCocoaAppOutputFileNamesAppendageKey]];
    // shouldRenameOutputFiles
    [self setShouldRenameOutputFiles:
     [[definition valueForKey:TKComponentCocoaAppShouldRenameOutputFilesKey]
      boolValue]];    
    // if we are using relative paths...
    if([[definition valueForKey:TKComponentCocoaAppShouldUseRelativePathsKey] 
        boolValue]) {
      // appPath (relative to main bundle)
      [self setAppPath:[[[[NSBundle mainBundle] bundlePath]
                         stringByAppendingPathComponent:
                         [definition valueForKey:TKComponentCocoaAppPathKey]]
                        stringByStandardizingPath]];
      // inputDir (relative)
      [self setInputDir:[[appPath stringByAppendingPathComponent:
                          TKComponentCocoaAppInputDirKey] 
                         stringByStandardizingPath]];
      // outputDir (relative)
      [self setOutputDir:[[appPath stringByAppendingPathComponent:
                          TKComponentCocoaAppOutputDirKey]
                          stringByStandardizingPath]];
    } else { // we are using absolute paths
      // appPath (absolute)
      [self setAppPath:
       [[definition valueForKey:TKComponentCocoaAppPathKey]
        stringByStandardizingPath]];
      // inputDir (absolute)
      [self setInputDir:
       [[definition valueForKey:TKComponentCocoaAppInputDirKey]
        stringByStandardizingPath]];
      // outputDir (absolute)
      [self setOutputDir:
       [[definition valueForKey:TKComponentCocoaAppOutputDirKey]
        stringByStandardizingPath]];
    }
    [self setMoveQueue:delegate.delegate.moveQueue];
    DLog(@"Set Move Queue:%@",moveQueue);
    // return
    return self;
  }
  // must have been an error, return nil
  return nil; 
}

- (BOOL)isClearedToBegin {
  // we will be moving files around, so lets grab a referene to the
  // default file manager
  NSFileManager *fm = [NSFileManager defaultManager];
  // is the app path valid
  if(![fm fileExistsAtPath:appPath]) {
    NSLog(@"No file is found at %@",appPath);
    return NO;
  }
  // copy support files
  if(![self copySupportFiles]) {
    return NO;
  }
  // you might think to check that output dir exists as well, but
  // it is possible that the application creates this dir on the fly
  // ---------------------------------------------------------------
  // if we made it here, we are good to go!!!
  return YES;
}

/**
 Perform any clean up code nescesary - this will include moving 
 generated data files into our sessions data directory
 */
- (void)tearDown {
  // if this is the first run... then queue the output files
  if([delegate runCount]==1) [self queueOutputFiles];
  [self cleanInputDirectory]; // clean input directory
}
  
@end

NSString * const TKComponentDataDirectoryKey = @"TKComponentDataDirectory";
NSString * const TKComponentCocoaAppPathKey = @"TKComponentCocoaAppPath";
NSString * const TKComponentCocoaAppTaskNameKey = @"TKComponentCocoaAppTaskName";
NSString * const TKComponentCocoaAppInputDirKey = @"TKComponentCocoaAppInputDir";
NSString * const TKComponentCocoaAppSupportFilesKey = @"TKComponentCocoaAppSupportFiles";
NSString * const TKComponentCocoaAppOutputDirKey = @"TKComponentCocoaAppOutputDir";
NSString * const TKComponentCocoaAppOutputFilesToCopyKey = @"TKComponentCocoaAppOutputFilesToCopy";
NSString * const TKComponentCocoaAppOutputFileNamesAppendageKey = @"TKComponentCocoaAppOutputFileNamesAppendage";
NSString * const TKComponentCocoaAppShouldRenameOutputFilesKey = @"TKComponentCocoaAppShouldRenameOutputFiles";
NSString * const TKComponentCocoaAppShouldUseRelativePathsKey = @"TKComponentCocoaAppShouldUseRelativePaths";
  

