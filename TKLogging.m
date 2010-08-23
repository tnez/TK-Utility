/***************************************************************
 
 TKLogging.m
 TKUtility
 
 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKLogging.h"


@implementation TKLogging

@synthesize filesWrittenTo,logQueue,count;

-(void) writeToDirectory:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite withOffset:(NSNumber *)offset{
	count++;
	@synchronized(self){
		NSString * fullPath=[directory stringByAppendingPathComponent:file];
		if([filesWrittenTo valueForKey:fullPath]==nil){
			NSString * stringToWrite=[NSString stringWithString:@""];
			[self createDirectoryIfNeeded:directory];
			if(shouldOverwrite||![TKLogging fileExists:fullPath]){
				[stringToWrite writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
			}
			[filesWrittenTo setObject:@"1" forKey:fullPath];
		}

		NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:fullPath];
		if([offset longValue]>=0){
			[output seekToFileOffset:[offset longValue]];
		}else{
			[output seekToEndOfFile];
		}
		[output writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	}
	count--;
}

-(void)writeToDirectory:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite{
	// create directory if needed
	[self createDirectoryIfNeeded:directory];
	// create empty file if needed
	if(![[NSFileManager defaultManager] fileExistsAtPath:[directory stringByAppendingPathComponent:file]]) {
		[[NSFileManager defaultManager] createFileAtPath:[directory stringByAppendingPathComponent:file] contents:nil attributes:nil];
	}
	// write to file
	[self writeToDirectory:directory file:file contentsOfString:string overWriteOnFirstWrite:shouldOverwrite withOffset:[NSNumber numberWithLong:-1]];
}

-(void) queueLogMessage:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite{
  [self queueLogMessage:directory file:file contentsOfString:string overWriteOnFirstWrite:shouldOverwrite withOffset:[NSNumber numberWithLong:-1]];
}

-(void) queueLogMessage:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite withOffset:(NSNumber *)offset{
	count++;
	@synchronized(self){
		TKLogQueueItem * queueItem=[[TKLogQueueItem alloc] init];
		[queueItem setDirectory:directory];
		[queueItem setFile:file];
		[queueItem setLogMessage:string];
		[queueItem setOverwrite:shouldOverwrite];
		[queueItem setOffset:offset];
		[logQueue addObject:queueItem];
	}
}

-(void)createDirectoryIfNeeded:(NSString *)directory{
  // If this directory does not exist create the directory.
  BOOL isDirectory = NO;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
  if ( !fileExists || !isDirectory ) {
    // Create the directory
    [[NSFileManager defaultManager] createDirectoryAtPath:directory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
  }
}

+(BOOL) fileExists:(NSString *) path{
  BOOL isDirectory = NO;
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
  return fileExists;
}

+(NSString *)getCurrentAppDirectory{
  NSString * resultsPath=[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
  return resultsPath;
}

+(void) spawnMainLogger:(id)param{

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  TKLogging * mainLogger=[TKLogging mainLogger];
  [mainLogger logLoop];

  [pool release];

}

+(void) spawnCrashRecoveryLogger:(id)param{

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  TKLogging * crashRecoveryLogger=[TKLogging crashRecoveryLogger];
  [crashRecoveryLogger logLoop];

  [pool release];

}

+(TKLogging *) crashRecoveryLogger{

  static TKLogging *crashRecoveryLogger;

  @synchronized(self)
    {
      if (crashRecoveryLogger == NULL){
        crashRecoveryLogger = [[self alloc] init];
      }
    }
  return (crashRecoveryLogger);
}

+(TKLogging *) mainLogger{

  static TKLogging *mainLogger;

  @synchronized(self)
    {
      if (mainLogger == NULL){
        mainLogger = [[self alloc] init];
      }
    }
  return (mainLogger);
}

-(id)init{
  if([super init]){
		count = 0;
    filesWrittenTo = [[NSMutableDictionary alloc] init];
    logQueue = [[NSMutableArray alloc] init];
    return self;
  }
  return nil;
}

-(void)logLoop{
  struct timespec ts;
  ts.tv_sec = 0;
  //Theoretically will run at most every millisecond
  ts.tv_nsec = 1000000;

	//always
	while(1){
		@synchronized(self){
			while([logQueue count] > 0){
				TKLogQueueItem * queueItem = [logQueue objectAtIndex:0];
				[logQueue removeObject:queueItem];
				[self writeToDirectory:[queueItem directory] file:[queueItem file] contentsOfString:[queueItem logMessage] overWriteOnFirstWrite:[queueItem overwrite] withOffset:[queueItem offset]];
				count--;
			}
		}
		nanosleep(&ts, NULL);
	}
}
	
+(NSInteger) unwrittenItemCount {
	return [[TKLogging mainLogger] count] + [[TKLogging crashRecoveryLogger] count];
}

@end
