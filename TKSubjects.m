////////////////////////////////////////////////////////////
//  TKSubjects.m
//  TK-Utility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////

#import "TKSubjects.h"

@implementation TKSubjects

@synthesize subjects;

-(void) dealloc {
    [subjects release]; subjects=nil;
	[super dealloc];
}

-(id) init {
	if(self=[super init]) {
		return self;
	} else {
		return nil;
	}
}

-(void) add {
	[subjects addObject:[NSMutableDictionary dictionaryWithObject:@"New Subject" forKey:@"name"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];    
}

-(void) clear {
	// clear each object . . . don't want to change id because it will mess up interface builder connections
	while([subjects lastObject]) {
		[subjects removeLastObject];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];    
}

-(void) clearDataForKey:(NSString *) key {
    for(NSInteger i=0; i<[self count]; i++) {
        [[self objectAtIndex:i] removeObjectForKey:key];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];
}

-(NSInteger) count {
	return [subjects count];
}

-(NSMutableDictionary *) objectAtIndex:(NSInteger) index {
	return [subjects objectAtIndex:index];
}

-(void) removeSubjects:(NSIndexSet *) selectionSet {
    if([selectionSet count] > 0) {    
        [subjects removeObjectsAtIndexes:selectionSet];
        [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];
    }
}

-(void) readSubjectsFromFile: (NSString *)pathToSubjectsFile {
	[self setSubjects:[NSMutableArray arrayWithContentsOfFile:pathToSubjectsFile]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];    
}

-(void) sortUsingDescriptors:(NSArray *) newDescriptors {
	[subjects sortUsingDescriptors:newDescriptors];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];
}

-(void) writeSubjectsToFile: (NSString *)pathToSubjectsFile {
	[subjects writeToFile:pathToSubjectsFile atomically:YES];
}

#pragma mark Table View Data Source Protocol

-(NSInteger) numberOfRowsInTableView:(NSTableView *) table {
	return [subjects count];
}

-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors {
	NSArray *newDescriptors = [table sortDescriptors];
    [subjects sortUsingDescriptors:newDescriptors];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];
}

-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	[[subjects objectAtIndex:row] setValue:newObject forKey:[column identifier]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TKSubjectsDidChangeNotification object:self];        
}

-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	return [[subjects objectAtIndex:row] valueForKey:[column identifier]];
}

@end

NSString * const TKSubjectsDidChangeNotification = @"TKSubjectsDidChangeNotification";
