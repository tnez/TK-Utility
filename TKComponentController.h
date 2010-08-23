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
#import "TKDelimitedFileParser.h"
#import "TKLibrary.h"
#import "TKLogging.h"
#import "TKSubject.h"
#import "TKTime.h"

#define DATAFILE [NSString stringWithFormat:@"%@_%@_%@_%@",STUDY,SUBJECT_ID,SHORTDATE,TASK]
#define LONGDATE [[NSDate date] description]
#define PREFERENCE_NIB [dictionary valueForKey:TKComponentPreferencesNibNameKey]
#define SESSION [subject session]
#define SHORTDATE [self shortdate]
#define STUDY [subject study]
#define SUBJECT_ID [subject code]
#define TASK [definition valueForKey:TKComponentNameKey]
#define VIEW_NIB [dictionary valueForKey:TKComponentViewNibNameKey]

@interface TKComponentController : NSObject {
	id delegate;
	IBOutlet NSView *view;
    NSDictionary *definition;
    NSString *dataDirectory;
    NSWindow *sessionWindow;
    TKLogging *mainLog;
    TKLogging *crashLog;
    TKSubject *subject;
	TKTime componentStartTime;
	TKTime componentEndTime;    
}
@property (assign) id delegate;
@property (nonatomic, copy) NSString *dataDirectory;
@property (assign) IBOutlet NSView *view;
@property (assign) NSWindow *sessionWindow;
@property (assign) TKSubject *subject;
@property (readonly) TKTime componentStartTime;
@property (readonly) TKTime componentEndTime;

/**
 This method adds general header and run headers as needed. If a different header or run header is needed then override this method in the sub-class.
 */
-(void) addHeadersAsNeeded;

/**
 This method actually begins the component, bringing the view up on the screen and starting the procedure.
 Should be overridden in subclass then passed to super.
 */
- (void)begin;

/**
 Ends the component, hiding view and releasing resources. Normally will not be called from outside the bundle except when early termination is required.
 Should be overridden in subclass then passed to super.
 */
- (void)end;

/**
 Preflight check. Called from outside bundle before sending begin message.
 Should be overridden in subclass then passed to super.Should be overriden in subclass then passed to super.
 */
- (BOOL)isClearedToBegin;

/**
 Way to load procedure bundle from the session. Normal instantiation will consist of this message, followed by a preflight check (isClearedToBegin) followed by the begin message.
 Will setup the definition dictionary for the component.
 This should not be overridden.
 */
+ (id)loadFromDefinition: (NSDictionary *)newDefinition;

/**
 Run count for given file in directory. Returns 1 if file does not exist, otherwise looks for instances or previous runs and returns previous runs plus one.
 */
- (NSInteger)runCountForFile: (NSString *)dataFileName inDirectory: (NSString *)dataDirectory;

@end

#pragma mark Preference Keys
/** Preference Keys */
extern NSString * const TKComponentTypeKey;
extern NSString * const TKComponentNameKey;
extern NSString * const TKComponentBundleIdentifierKey;
extern NSString * const TKComponentViewNibNameKey;
extern NSString * const TKComponentPreferencesNibNameKey;
extern NSString * const TKComponentPreferencesFileNameKey;
extern NSString * const TKComponentPreferencesFileTypeKey;

#pragma mark Enumerations
/** Enumerated Values */
enum {
    TKComponentBundleType           = 0,
    TKComponentCocoaAppType         = 1,
    TKComponentFutureBasicAppType   = 2
}   TKComponentType;

#pragma mark Notifications
/** Notifications */
extern NSString * const TKComponentDidBeginNotification;
extern NSString * const TKComponentDidFinishNotification;


@interface TKComponentController(TKComponentControllerPrivate)
- (void)loadView;
- (void)setDefinition: (NSDictionary *)newDefinition;
- (NSString *)shortdate;
- (void)throwError: (NSString *)errorDescription andBreak: (BOOL)shouldBreak;
@end
