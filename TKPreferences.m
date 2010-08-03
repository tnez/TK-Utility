/***************************************************************
 
 TKPreferences.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKPreferences.h"


@implementation TKPreferences
@synthesize data, file, filename, filepath, isDirty, nibName, window;

-(void) dealloc {
	[data release];
	[file release];
	[filename release];
	[filepath release];
	[nibName release];
	[super dealloc];
}	
	
+(TKPreferences *) defaultPrefs {
	static TKPreferences* prefs;
	if(prefs==NULL) {
		prefs = [[TKPreferences alloc] init];
	}
	return(prefs);
}

-(TKPreferences *) init {
	if(self=[super init]) {
		isDirty = YES; // TODO: implement isDirty so that we don't save if no change
		filename = [[NSString stringWithString:TK_PREFS_DEFAULT_FILE_NAME] retain];
		filepath = [[[NSBundle mainBundle] resourcePath] retain];
		file = [[filepath stringByAppendingPathComponent:filename] retain];
		[self setNibName:TK_PREFS_DEFAULT_NIB_NAME];
		[self read];
		return self;
	} else {
		return nil;
	}
}

-(IBAction) open:(id) sender {
	[NSBundle loadNibNamed:nibName owner:self];
	[window setDelegate:self];
	[window makeKeyAndOrderFront: self];
}

-(void) read {
	[self setData:[NSMutableDictionary dictionaryWithContentsOfFile:file]];
	if(!data) {
		[self setData:[NSMutableDictionary dictionary]];
	}
}

-(IBAction) save:(id) sender {
	if([self isDirty]) {
		[self write];
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"preferencesDidChange" object:self];
	} else {

	}
}

-(void) setValue:(id) theValue forKey:(NSString *) theKey {
	[self willChangeValueForKey: theKey];
	[data setValue:theValue forKey: theKey];
	[self didChangeValueForKey: theKey];
}

-(id) valueForKey:(NSString *) key {
	return [data valueForKey:key];
}

-(void) windowWillClose:(NSNotification *) notification {
	[self save:self];
}

-(void) write {
	[data writeToFile:file atomically:NO];
}

@end
