/***************************************************************
 
 TKLogging.h
 TKUtility
 
 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>
#import "TKLogQueueItem.h"
#import "TKNotificationQueueItem.h"
#import "TKPreferences.h"
#import "TKTimer.h"

#define TKLOGGING_DEFAULT_ENCODING NSUTF8StringEncoding
#define TKLOGGING_DEFAULT_FIELD_DELIMITER @"\t"
#define TKLOGGING_DEFAULT_GROUP_DELIMITER @"\n"
#define TKLOGGING_DEFAULT_RECORD_DELIMITER @"\n"

@interface TKLogging : NSObject {
	TKPreferences *prefs;
	NSMutableDictionary * filesWrittenTo;
	NSMutableArray * logQueue;
	NSInteger count;
	NSString *dataDirectory;
	NSString *fieldDelimiter;
	NSString *fileName;
	NSString *groupDelimiter;
	NSString *recordDelimiter;
	NSStringEncoding encoding;
}
@property (assign) TKPreferences *prefs;
@property (nonatomic,retain) NSMutableDictionary * filesWrittenTo;
@property (nonatomic,retain) NSMutableArray *logQueue;
@property (readwrite) NSInteger count;
@property (nonatomic, retain)	NSString *dataDirectory;
@property (nonatomic, retain)	NSString *fieldDelimiter;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain)	NSString *groupDelimiter;
@property (nonatomic, retain)	NSString *recordDelimiter;
@property (readwrite) NSStringEncoding encoding;
//NOTE: Should be used only in apps that do not periodically write data and do not require timing. writing to files takes extra time so it will slow things down
//      to write to a file in an app that requires precise timing, you should spawn a logger, the queue a log message
-(void) writeToDirectory:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite withOffset:(NSNumber *)offset;
-(void) writeToDirectory:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite;

+(NSString *)getCurrentAppDirectory;
-(void) queueLogMessage:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite;
-(void) queueLogMessage:(NSString *)directory file:(NSString *)file contentsOfString:(NSString *)string overWriteOnFirstWrite:(BOOL)shouldOverwrite withOffset:(NSNumber *)offset;
-(void)createDirectoryIfNeeded:(NSString *)directory;
+(BOOL) fileExists:(NSString *) path;
+(TKLogging *) crashRecoveryLogger;
+(TKLogging *) mainLogger;
-(void) insertGroupDelimiter;
-(void) logString: (NSString *) string;
-(void) logLoop;
+(void) spawnMainLogger:(id)param;
+(void) spawnCrashRecoveryLogger:(id)param;
+(NSInteger) unwrittenItemCount; // returns count of main logger + count of crash recovery logger

@end
