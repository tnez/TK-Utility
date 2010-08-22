////////////////////////////////////////////////////////////
//  TKSubject.h
//  TKUtility
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/22/10
//  Copyright 2010 smoooosh software. All rights reserved.
/////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>
@interface TKSubject : NSObject {
    NSString *code;
    NSString *session;
    NSString *name;
    NSString *drug;
    NSString *dose;
}
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *session;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *drug;
@property (nonatomic, copy) NSString *dose;
@end
