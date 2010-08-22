//
//  TKVsController.h
//  TKUtility
//
//  Created by Travis Nesland on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "TKComponentController.h"
#import "TKQuestionSet.h"
#import "TKQuestion.h"

#pragma mark Preference Keys
#define TK_VS_NUMBER_OF_INTENDED_QUESTIONS_KEY @"TKVsNumberOfIntendedQuestions"
#define TK_VS_QUESTION_ACCESS_METHOD_KEY @"TKVsQuestionAccessMethod"
#define TK_VS_QUESTION_FILE_FULL_PATH_KEY @"TKVsQuestionFullPath"

@interface TKVsController : TKComponentController {
	TKQuestionSet *questionSet;
	TKQuestion *question;
	TKTime questionStartTime;
	NSInteger numberOfIntendedQuestions;
	NSInteger numberOfQuestionsAsked;
    NSInteger questionAccessMethod;
    NSString *questionFileFullPath;
}
@property (nonatomic, retain) TKQuestionSet *questionSet;
@property (nonatomic, retain) TKQuestion *question;
@property (readonly) TKTime questionStartTime;
@property (readwrite) NSInteger numberOfIntendedQuestions;
@property (readonly) NSInteger numberOfQuestionsAsked;
@property (readwrite) NSInteger questionAccessMethod;
@property (nonatomic, retain) NSString *questionFileFullPath;
-(void) begin;
-(void) end;
@end
@interface TKVsController (TKVsControllerPrivate)
-(void) loadNextQuestion;
-(void) resetInterface;
-(void) userDidRespond:(NSInteger) response;
@end
