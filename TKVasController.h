/***************************************************************
 
 TKVasController.h
 TKUtility

 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>

 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.

 LastMod: 20100803 - tn

 IN (Information To Be Provided By Preferences)
 --------------------------------------------------------------
 vasLeftPrompt
 vasMidPrompt
 vasRightPrompt
 vasNumberOfTickMarks
 
 OUT (Event Information)
 --------------------------------------------------------------
 questionID = id of the question that was presented to the user
 response	= integer value of slider
 latency = time elapsed from presentation to submital 0.000000
 questionText = the actual question presented
 
***************************************************************/

#import <Cocoa/Cocoa.h>
#import "TKComponentController.h"
#import "TKPreferences.h"
#import "TKQuestionSet.h"

#define TKVAS_DEFAULT_LEFT_LABEL_TEXT @"0"
#define TKVAS_DEFAULT_MID_LABEL_TEXT @""
#define TKVAS_DEFAULT_RIGHT_LABEL_TEXT @"100"
#define TKVAS_DEFAULT_NUMBER_OF_TICK_MARKS 2
#define TKVAS_DEFAULT_QUESTION_ACCESS_METHOD TKQuestionSetSequentialAccess
#define TKVAS_DEFAULT_SLIDER_MIN_VALUE 0
#define TKVAS_DEFAULT_SLIDER_MAX_VALUE 100
#define TKVAS_DEFAULT_NIB_FILE @"TKVasView"

@interface TKVasController : TKComponentController {
  TKQuestionSet *questionSet;
  TKQuestion *question;
  TKTime questionStartTime;
	NSString *leftLabelText;
	NSString *midLabelText;
	NSString *rightLabelText;
	NSInteger sliderMinValue;
	NSInteger sliderMaxValue;
	NSInteger numberOfIntendedQuestions;
	NSInteger numberOfQuestionsAsked;
	NSInteger numberOfTickMarks;	
	IBOutlet NSButton *button;
	IBOutlet NSSlider *slider;
	IBOutlet NSTextField *text;
}
@property(nonatomic, retain) TKQuestionSet *questionSet;
@property(nonatomic, retain) TKQuestion *question;
@property(nonatomic, retain) NSString *leftLabelText;
@property(nonatomic, retain) NSString *midLabelText;
@property(nonatomic, retain) NSString *nibFileName;
@property(nonatomic, retain) NSString *rightLabelText;
@property(readwrite) NSInteger sliderMinValue;
@property(readwrite) NSInteger sliderMaxValue;
@property(readwrite) NSInteger numberOfIntendedQuestions;
@property(readwrite) NSInteger numberOfQuestionsAsked;
@property(readwrite) NSInteger numberOfTickMarks;
@property(assign) IBOutlet NSButton *button;
@property(assign) IBOutlet NSSlider *slider;
@property(assign) IBOutlet NSTextField *text;
-(void) begin;
-(void) end;
-(id) init;
-(id) initWithQuestions:(TKQuestionSet *) questionSet;
-(void) loadPreferences:(NSNotification *) aNotification;
-(IBAction) submitButton:(id) sender;
-(IBAction) sliderHasChanged:(id) sender;
@end

// PRIVATE METHODS
@interface TKVasController ()
-(void) loadNextQuestion;
@end
