////////////////////////////////////////////////////////////
//  TKSubject.h
//  TK-Utility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>

@interface TKSubject : NSObject {
    NSDictionary                             *info;
}
@property (nonatomic, retain) NSDictionary   *info;
- (id)initWithDictionary: (NSDictionary *)subjectInformation;
- (NSString *)identifier;
- (NSString *)study;
- (NSString *)session;
- (NSString *)dose;
- (NSString *)level;
- (NSString *)code;
- (NSString *)name;
- (NSString *)drug;
- (NSString *)lastRun;
- (NSDictionary *)additionalInfo;
@end

extern NSString * const TKSubjectIdentifierKey;
extern NSString * const TKSubjectStudyKey;
extern NSString * const TKSubjectSessionKey;
extern NSString * const TKSubjectDoseKey;
extern NSString * const TKSubjectLevelKey;
extern NSString * const TKSubjectCodeKey;
extern NSString * const TKSubjectNameKey;
extern NSString * const TKSubjectDrugKey;
extern NSString * const TKSubjectLastRunKey;
