////////////////////////////////////////////////////////////
//  TKSubjects.h
//  TK-Utility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "TKSubject.h"

@interface TKSubjects : NSObject {
	NSMutableArray *subjects;
}
@property (retain) NSMutableArray *subjects;
-(void) add;
-(void) clear;
-(void) clearDataForKey:(NSString *) key;
-(NSInteger) count;
-(NSMutableDictionary *) objectAtIndex:(NSInteger) index;
-(void) readSubjectsFromFile: (NSString *)pathToSubjectsFile;
-(void) removeSubjects: (NSIndexSet *)index;
-(void) sortUsingDescriptors: (NSArray *)newDescriptors;
-(void) writeSubjectsToFile: (NSString *)pathToSubjectsFile;

#pragma mark Table View Data Source Protocol
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table;
-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors;
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row;
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row;

@end

#pragma mark Notifications
extern NSString * const TKSubjectsDidChangeNotification;
