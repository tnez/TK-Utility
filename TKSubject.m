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
@synthesize subject_id,study,session,drugDose,drugLevel,drugCode,drug;

/** HOUSEKEEPING */
- (void)dealloc {
    [subject_id release];
    [study release];
    [session release];
    [drugDose release];
    [drugLevel release];
    [drugCode release];
    [drug release];
    [super dealloc];
}

- (id)init {
    if(self=[super init]) {
        return self;
    } return nil;
}

- (id)initWithDictionary: (NSDictionary *)subjectInformation {
    if(self=[self init]) {
        [self setSubject_id:[subjectInformation valueForKey:TKSubjectIdentifierKey]];
        [self setStudy:[subjectInformation valueForKey:TKSubjectStudyKey]];
        [self setSession:[subjectInformation valueForKey:TKSubjectSessionKey]];
        [self setDrugDose:[subjectInformation valueForKey:TKSubjectDrugDoseKey]];
        [self setDrugLevel:[subjectInformation valueForKey:TKSubjectDrugLevelKey]];
        [self setDrugCode:[subjectInformation valueForKey:TKSubjectDrugCodeKey]];
        [self setDrug:[subjectInformation valueForKey:TKSubjectDrugKey]];
        return self;
    }
    return nil;
}

@end

NSString * const TKSubjectIdentifierKey = @"TKSubjectIdentifier";
NSString * const TKSubjectStudyKey = @"TKSubjectStudy";
NSString * const TKSubjectSessionKey = @"TKSubjectSession";
NSString * const TKSubjectDrugDoseKey = @"TKSubjectDose";
NSString * const TKSubjectDrugLevelKey = @"TKSubjectLevel";
NSString * const TKSubjectDrugCodeKey = @"TKSubjectCode";
NSString * const TKSubjectDrugKey = @"TKSubjectDrug";
