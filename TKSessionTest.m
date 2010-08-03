//
//  TKSessionTest.m
//  TKUtility
//
//  Created by tnesland on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GTMSenTestCase.h"
#import <TKUtility/TKUtility.h>

@interface TKSessionTest : GTMTestCase {
  TKSession *session;
}
@end

@implementation TKSessionTest

-(void) setUp {
  session = [[TKSession alloc] init];
}

-(void) tearDown {
  [session release];
}

-(void) testUuid {
  STAssertNotNULL([session uuid],@"SessionID should not be null");
}

-(void) testStartTime {
  [session begin];
  STAssertNotNULL([session startTimeDesc],@"StartTime should not be null");
}

@end
