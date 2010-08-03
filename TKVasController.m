/***************************************************************
 
 TKVasController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKUtility.h"

@implementation TKVasController

@synthesize questionSet,question,leftLabelText,midLabelText,rightLabelText,
sliderMinValue,sliderMaxValue,numberOfIntendedQuestions,numberOfQuestionsAsked,
numberOfTickMarks,slider,button,text;

-(void) begin {
	if(numberOfIntendedQuestions<1) {
		NSLog(@"Tried to begin VAS component without setting number of intended questions");
		return;
	}
	// LOAD AND CONNECT NIB
  [NSBundle loadNibNamed:nibFileName owner:self];
	[self loadPreferences:nil];
	[self loadView];
  [self loadNextQuestion];
}

-(void) dealloc {
  [questionSet release];
  [question release];
	[leftLabelText release];
	[midLabelText release];
	[rightLabelText release];
  [super dealloc];
}

-(void) end {
	[view exitFullScreenModeWithOptions:nil];
	[delegate componentDidFinish: self];
}

-(id) init {
  if(self=[super init]) {
		numberOfIntendedQuestions=0;
		numberOfQuestionsAsked=0;
		sliderMinValue = TKVAS_DEFAULT_SLIDER_MIN_VALUE;
		sliderMaxValue = TKVAS_DEFAULT_SLIDER_MAX_VALUE;
		[self setNibFileName:TKVAS_DEFAULT_NIB_FILE];
		[[NSNotificationCenter defaultCenter] addObserver:self
																						 selector:@selector(loadPreferences:)
																								 name:@"preferencesDidChange"
																								object:nil];
    return self;
  }
  return nil;
}

-(id) initWithQuestions:(TKQuestionSet *) questions {
  if([self init]) {
    [self setQuestionSet:questions];
		numberOfIntendedQuestions=[questionSet count];
    return self;
  }
  return nil;
}

-(void) loadPreferences:(NSNotification *) aNote {
	id prefs = [TKPreferences defaultPrefs];
	[self setLeftLabelText:[prefs valueForKey:@"vasLeftPrompt"]];
	[self setMidLabelText:[prefs valueForKey:@"vasMidPrompt"]];
	[self setRightLabelText:[prefs valueForKey:@"vasRightPrompt"]];
	[self setNumberOfTickMarks:[[prefs valueForKey:@"vasNumberOfTickMarks"] integerValue]];
	[slider setNumberOfTickMarks:numberOfTickMarks];
	[questionSet setAccessMethod:[[prefs valueForKey:@"vasQuestionAccessMethod"] integerValue]];
	if(![[prefs valueForKey:@"vasNumberOfIntendedQuestions"] isEqualTo:[NSNumber numberWithInteger:0]]) {
		// if vasNumberOfIntendedQuestions is not equal to zero, then set
		numberOfIntendedQuestions = [[prefs valueForKey:@"vasNumberOfIntendedQuestions"] integerValue];
	}
}

-(void) loadNextQuestion {
	// if no more questions or we have reached number of
	// intended questions...
  if([questionSet isEmpty] ||
		 numberOfQuestionsAsked>=numberOfIntendedQuestions) {
		[self end];
  } else { //...we have more questions; continue
    [self setQuestion:[questionSet nextQuestion]];
		[button setEnabled:NO];
    [slider setIntValue:sliderMinValue];
		[text setStringValue:[question text]];
    questionStartTime = current_time_marker();
  }
}

-(IBAction) sliderHasChanged:(id) sender {
	if(![button isEnabled]) {
		[button setEnabled:YES];
	}
}

-(IBAction) submitButton:(id) sender {
	if([delegate respondsToSelector:@selector(event:didOccurInComponent:)]) {
		TKTime latency = time_since(questionStartTime);
		NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
		[args setValue:[question uid] forKey:@"questionID"];
		[args setValue:[NSString stringWithFormat:@"%d",[slider integerValue]] forKey:@"response"];
		[args setValue:[NSString stringWithFormat:@"%d.%06d",latency.seconds,latency.microseconds] forKey:@"latency"];
		[args setValue:[question text] forKey:@"questionText"];
		[delegate event:[args autorelease] didOccurInComponent:self];
	}
	numberOfQuestionsAsked++;
  [self loadNextQuestion];
}

@end
