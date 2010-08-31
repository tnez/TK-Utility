////////////////////////////////////////////////////////////
//  TKSubject.m
//  TK-Utility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/30/10
//  Copyright 2010 smoooosh software. All rights reserved.
/////////////////////////////////////////////////////////////
#import "TKSubject.h"

@implementation TKSubject
@synthesize info;

/** HOUSEKEEPING */
- (void)dealloc {
    [info release];
    [super dealloc];
}
- (id)initWithDictionary: (NSDictionary *)subjectInformation {
    if(self=[super init]) {
        info = [subjectInformation copy];
        return self;
    }
    return nil;
}

/** ACCESSORS */
- (NSString *)identifier {
    return [info valueForKey:TKSubjectIdentifierKey];
}
- (NSString *)study {
    return [info valueForKey:TKSubjectStudyKey];
}
- (NSString *)session {
    return [info valueForKey:TKSubjectSessionKey];
}
- (NSString *)dose {
    return [info valueForKey:TKSubjectDoseKey];
}
- (NSString *)level {
    return [info valueForKey:TKSubjectLevelKey];
}
- (NSString *)code {
    return [info valueForKey:TKSubjectCodeKey];
}
- (NSString *)name {
    return [info valueForKey:TKSubjectNameKey];
}
- (NSString *)drug {
    return [info valueForKey:TKSubjectDrugKey];
}
- (NSString *)lastRun {
    return [info valueForKey:TKSubjectLastRunKey];
}
- (NSDictionary *)additionalInfo {
    return info;
}
@end

NSString * const TKSubjectIdentifierKey = @"TKSubjectIdentifier";
NSString * const TKSubjectStudyKey = @"TKSubjectStudy";
NSString * const TKSubjectSessionKey = @"TKSubjectSession";
NSString * const TKSubjectDoseKey = @"TKSubjectDose";
NSString * const TKSubjectLevelKey = @"TKSubjectLevel";
NSString * const TKSubjectCodeKey = @"TKSubjectCode";
NSString * const TKSubjectNameKey = @"TKSubjectName";
NSString * const TKSubjectDrugKey = @"TKSubjectDrug";
NSString * const TKSubjectLastRunKey = @"TKSubjectLastRun";
