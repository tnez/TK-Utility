////////////////////////////////////////////////////////////
//  TKSubject.m
//  TKUtility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/22/10
//  Copyright 2010 smoooosh software. All rights reserved.
/////////////////////////////////////////////////////////////
#import "TKSubject.h"

@implementation TKSubject
@synthesize code,dose,drug,name,session,study;
-(void) dealloc {
    [code release];
    [dose release];
    [drug release];
    [name release];
    [session release];
    [study release];
    [super dealloc];
}
@end
