//
//  TKVsController.m
//  TKUtility
//
//  Created by Travis Nesland on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "TKVsController.h"
@implementation TKVsController
@synthesize questionSet, question, questionStartTime, numberOfIntendedQuestions, numberOfQuestionsAsked,
questionAccessMethod, questionFileFullPath;
#pragma mark Housekeeping
-(void) dealloc {
	[question release];
	[questionSet release];
    [questionFileFullPath release];
	[super dealloc];
}
-(void) awakeFromNib {
    // initialization of values
	numberOfQuestionsAsked=0;
    // load preferences
    [self loadPreferences];
    // attempt to load questions
    [self setQuestionSet:[[TKQuestionSet alloc] initFromFile:questionFileFullPath usingAccessMethod:questionAccessMethod]];
    if(!questionSet) { //question set did not load...
        [self throwError:[NSString stringWithFormat:@"Could not load question set from given file: %@",questionFileFullPath] andBreak:YES];
    } // (else)...continue with initialization
    if( numberOfIntendedQuestions < 1 ) {
        [self setNumberOfIntendedQuestions:[questionSet count]];
    }
    [self begin];
}
-(id) init {
	if(self=[super init]) {
		[self awakeFromNib];
		return self;
	}
	return nil;
}
#pragma mark Public Interface
-(void) begin {
    [super begin];
	[self loadNextQuestion];
}
-(void) end {
    [super end];
}
#pragma mark Private Interface
-(void) loadNextQuestion {
	// if no more questions or we have reached number of
	// intended questions...
	if([questionSet isEmpty] || numberOfQuestionsAsked>=numberOfIntendedQuestions) {
		[self end];
	} else { //...we have more questions; continue
		[self setQuestion:[questionSet nextQuestion]];
		questionStartTime = current_time_marker();
		[self resetInterface];
	}
}
-(void) loadPreferences {
    [self setNumberOfIntendedQuestions:[[definition valueForKey:TK_VS_NUMBER_OF_INTENDED_QUESTIONS_KEY] integerValue]];
    [self setQuestionAccessMethod:[[definition valueForKey:TK_VS_QUESTION_ACCESS_METHOD_KEY] integerValue]];
    [self setQuestionFileFullPath:[definition valueForKey:TK_VS_QUESTION_FILE_FULL_PATH_KEY]];
    [super loadPreferences];
}
-(void) userDidRespond:(NSInteger) response {
	if([delegate respondsToSelector:@selector(event:didOccurInComponent:)]) {
		TKTime latency = time_since(questionStartTime);
		NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
		[args setValue:[question uid] forKey:@"questionID"];
		[args setValue:[NSString stringWithFormat:@"%d",response] forKey:@"response"];
		[args setValue:[NSString stringWithFormat:@"%d.%06d",latency.seconds,latency.microseconds] forKey:@"latency"];
		[args setValue:[question text] forKey:@"questionText"];
		[delegate event:[args autorelease] didOccurInComponent:self];
	}
	[self loadNextQuestion];
}
#pragma mark Sub-Classed
-(void) resetInterface {
	// to be handled by sub-class
	return;
}
@end
