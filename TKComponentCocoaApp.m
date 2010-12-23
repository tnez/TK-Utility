//
//  TKComponentCocoaApp.m
//  TKUtility
//
//  Created by tnesland on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKComponentCocoaApp.h"
#import "TKComponentController.h"


@implementation TKComponentCocoaApp
@synthesize delegate,appPath,taskName,inputDir,outputDir,dataDir,inputFiles,
outputFilesToIgnore,shouldRenameOutputFiles;

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
    NSLog(@"The Cocoa Application: %@ failed to launch",appPath);
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
    NSLog(@"Waiting for pid:%d to end, not pid:%d",[pid integerValue],
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
      NSLog(@"There was an error removing the support file: %@... %@",
            fileName,[removalError localizedDescription]);
      // inrement the error counter
      errorCount++;
    } // end of error handling
  } // end of file processing loop
  // return success YES|NO
  return !(errorCount>0);
}

/**
 Copy output file to target -- if a target name is given this method
 will attempt to rename the file upon copy... can send nil if no rename
 is required
 If the copy fails the method logs the error and returns NO
 RETURN: YES upon success NO upon failure
 */
- (BOOL)copyOutputFile: (NSString *)filename asFileName: (NSString *)newName {
  // local variables used in rename process
  NSFileManager *fm = [NSFileManager defaultManager]; // ref to file manager
  NSError *copyError = nil;                           // error during copy  
  NSInteger attemptCount = 0;                         // int used to append
                                                      // unique name
  NSString *appendTag;                                // the appending string
                                                      // in order to create
                                                      // unique name
  NSString *currentExt;                               // the current extension
                                                      // of the given filename
  NSString *targetName;                               // the total target name
  BOOL determinedTargetName = NO;                     // have we determined a
                                                      // valid target name?

  // determine the current extension
  // if new name provided...
  if(newName) {
    // we will take the extension from the new name
    currentExt = [newName pathExtension];
  } else {
    // we will take the extension from the old name
    currentExt = [filename pathExtension];
  }
  // loop until we find a filename for our output file that does not currently
  // exist in the output directory
  while(!determinedTargetName) {
    // if first time...
    if(attemptCount==0) {
      // do nothing...
    } else { // this is not our first attempt
      // ...append our unique integer followed by file extension
      appendTag = [NSString stringWithFormat:@"_%d.%@",attemptCount,currentExt];
    }
    // create our target name
    // if we have a provided a target name base
    if(newName) {
      // ...then add append tag to new name
      targetName = [NSString stringWithString:
                    [[newName stringByDeletingPathExtension]
                     stringByAppendingString:appendTag]];
    } else { // keep same name base
      // ...then append tag to same name
      targetName = [NSString stringWithString:
                    [[filename stringByDeletingPathExtension]
                     stringByAppendingString:appendTag]];
    }
    // if the target name does not currently exist in the ouput directory
    // then we have successfully determined our target name
    determinedTargetName = ![fm fileExistsAtPath:
                             [outputDir stringByAppendingPathComponent:
                              targetName]];
    // increment attempt count for next go (if needed)
    attemptCount++;
  }
  // copy the file
  [fm copyItemAtPath:[outputDir stringByAppendingPathComponent:filename]
                toPath:[dataDir stringByAppendingPathComponent:targetName]
                 error:&copyError];
  // if there was an error...
  if(copyError) {
    // log the error
    NSLog(@"Error copying: %@ to: %@... %@",
          [outputDir stringByAppendingPathComponent:filename],
          [dataDir stringByAppendingPathComponent:newName],
          [copyError localizedDescription]);
    // return no to represent failure
    return NO;
  }
  // else successful copy - return YES to indicate success
  return YES;
}

/**
 Copy output files -- loop through all the output files and handle their
 copying according to shouldRenameOutputFile and outputFilesToIgnore
 parameters
 RETURN: YES if all files were copied successfully - otherwise NO
 */
- (BOOL)copyOutputFiles {
  NSFileManager *fm = [NSFileManager defaultManager]; // file manager ref
  NSArray *outputFiles;                               // stack of output files
  BOOL retValue = YES;                                // return value 
  // populate our output file list
  outputFiles = [fm contentsOfDirectoryAtPath:
                 [outputDir stringByStandardizingPath]
                                        error:nil];
  // populate our basename in the case we should rename
  NSString *basename = [NSString stringWithFormat:@"%@_%@_%@_%@.%@",
                        [[delegate subject] study],
                        [[delegate subject] subject_id],
                        taskName,
                        [delegate shortdate],
                        @"tsv"];
  // then for all found output files...
  for(NSString *fname in outputFiles) {
    // if said file path is found in ignore list...
    if([self shouldIgnoreOutputFile:fname]) {
      // ...then do nothing and move to next file
      continue;
    }
    // else... we're good to go...
    // if this is a rename process
    if(shouldRenameOutputFiles) {
      // attempt to copy output file
      // if attempt was successful...
      if([self copyOutputFile:fname asFileName:basename]) {
        // then remove the old file
        [self removeOutputFile:fname];
      } else { // there was some error
        // adjust return value to indicate error
        retValue = NO;
      }
    } else { // we are not to rename the file
      // attempt to copy output file
      // if the attempt was successful...
      if([self copyOutputFile:fname asFileName:nil]) {
        // then remove the old file
        [self removeOutputFile:fname];
      } else { // there was some error
        // adjust return value to indicate error
        retValue = NO;
      }
    } // end non-rename branch
  }   // end of looping through output files
  return retValue; // were we successful???
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
        NSLog(@"Error deleting the old support file: %@... %@",
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
      NSLog(@"Error copying: %@ to: %@... %@",
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
  [outputFilesToIgnore release];
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
    // set internal values
    // appPath
    [self setAppPath:
     [[definition valueForKey:TKComponentCocoaAppPathKey]
      stringByStandardizingPath]];
    // taskName
    [self setTaskName:
     [definition valueForKey:TKComponentCocoaAppTaskNameKey]];
    // inputDir
    [self setInputDir:
     [[definition valueForKey:TKComponentCocoaAppInputDirKey]
      stringByStandardizingPath]];
    // outputDir
    [self setOutputDir:
     [[definition valueForKey:TKComponentCocoaAppOutputDirKey]
      stringByStandardizingPath]];
    // dataDir
    [self setDataDir:
     [[definition valueForKey:TKComponentDataDirectoryKey]
      stringByStandardizingPath]];
    // inputFiles
    [self setInputFiles:
     [definition valueForKey:TKComponentCocoaAppSupportFilesKey]];
    // outputFilesToIgnore
    [self setOutputFilesToIgnore:
     [definition valueForKey:TKComponentCocoaAppOutputFilesToIgnoreKey]];
    // shouldRenameOutputFiles
    [self setShouldRenameOutputFiles:
     [[definition valueForKey:TKComponentCocoaAppShouldRenameOutputFilesKey]
      boolValue]];
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
 Remove output file from output directory
 RETURN: YES upon success, NO upon failure
 NOTE: errors are logged w/in method
 */
- (BOOL)removeOutputFile: (NSString *)filename {
  // grab ref to file manager
  NSFileManager *fm = [NSFileManager defaultManager];
  // create an empty error ptr
  NSError *removeError = nil;
  // attempt to remove file
  [fm removeItemAtPath:[[outputDir stringByAppendingPathComponent:filename]
                        stringByStandardizingPath]
                 error:&removeError];
  // if an error occurred...
  if(removeError) {
    // log the issue
    NSLog(@"Error removing file:%@ from:%@... %@",filename,
          [outputDir stringByStandardizingPath],
          [removeError localizedDescription]);
    // return no to indicate failure
    return NO;
  }
  // else, we're good, return YES to indicate success
  return YES;
}

/**
 Return yes if this output file is found in our ignore list
 */
- (BOOL)shouldIgnoreOutputFile: (NSString *)pathToOutputFile {
  // for every file path in our ignore list...
  for(NSString *ignoreFile in outputFilesToIgnore) {
    // if ignore path is equal to given path...
    if([[ignoreFile stringByStandardizingPath]
        isEqualToString:pathToOutputFile]) {
      // ...then we should ignore
      return YES;
    }
  } // end of for loop
  // if we've made it out of the loop, then no matches were found
  // so we should not ignore this file
  return NO;
}

/**
 Perform any clean up code nescesary - this will include moving 
 generated data files into our sessions data directory
 */
- (void)tearDown {
  // copy output files
  [self copyOutputFiles];
  // clean input directory
  [self cleanInputDirectory];
}
  
@end

NSString * const TKComponentDataDirectoryKey = @"TKComponentDataDirectory";
NSString * const TKComponentCocoaAppPathKey = @"TKComponentCocoaAppPath";
NSString * const TKComponentCocoaAppTaskNameKey = @"TKComponentCocoaAppTaskName";
NSString * const TKComponentCocoaAppInputDirKey = @"TKComponentCocoaAppInputDir";
NSString * const TKComponentCocoaAppSupportFilesKey = @"TKComponentCocoaAppSupportFiles";
NSString * const TKComponentCocoaAppOutputDirKey = @"TKComponentCocoaAppOutputDir";
NSString * const TKComponentCocoaAppOutputFilesToIgnoreKey = @"TKComponentCocoaAppOutputFilesToIgnore";
NSString * const TKComponentCocoaAppShouldRenameOutputFilesKey = @"TKComponentCocoaAppShouldRenameOutputFiles";

  

