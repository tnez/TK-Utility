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
#import "TKVsController.h"

#pragma mark Preference Keys
#define TK_VAS_LEFT_LABEL_KEY @"TKVasLeftLabel"
#define TK_VAS_MID_LABEL_KEY @"TKVasMidLabel"
#define TK_VAS_RIGHT_LABEL_KEY @"TKVasRightLabel"
#define TK_VAS_NUMBER_OF_TICK_MARKS_KEY @"TKVasNumberOfTickMarks"
#define TK_VAS_SLIDER_MIN_VALUE_KEY @"TKVasSliderMinValueKey"
#define TK_VAS_SLIDER_MAX_VALUE_KEY @"TKVasSliderMaxValueKey"

@interface TKVasController : TKVsController {
	NSString *leftLabelText;
	NSString *midLabelText;
	NSString *rightLabelText;
	double sliderMinValue;
	double sliderMaxValue;
	NSInteger numberOfTickMarks;	
	IBOutlet NSButton *button;
	IBOutlet NSSlider *slider;
	IBOutlet NSTextField *text;
}
@property(nonatomic, retain) NSString *leftLabelText;
@property(nonatomic, retain) NSString *midLabelText;
@property(nonatomic, retain) NSString *rightLabelText;
@property(readwrite) double sliderMinValue;
@property(readwrite) double sliderMaxValue;
@property(readwrite) NSInteger numberOfTickMarks;
@property(assign) IBOutlet NSButton *button;
@property(assign) IBOutlet NSSlider *slider;
@property(assign) IBOutlet NSTextField *text;
-(IBAction) submitButton:(id) sender;
-(IBAction) sliderHasChanged:(id) sender;
-(void) resetInterface;
@end
