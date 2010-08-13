/***************************************************************
 
 TKVasController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/
#import "TKVasController.h"
@implementation TKVasController
@synthesize leftLabelText,midLabelText,rightLabelText,sliderMinValue,sliderMaxValue,numberOfTickMarks,slider,button,text;
#pragma mark Housekeeping
-(void) dealloc {
	[leftLabelText release];
	[midLabelText release];
	[rightLabelText release];
	[super dealloc];
}
-(id) init {
	if(self=[super init]) {
		[self awakeFromNib];
		return self;
	}
	return nil;
}
#pragma mark Setup
-(void) awakeFromNib {
    [self loadPreferences];
    [super awakeFromNib];
}
-(void) loadPreferences {
    [self setLeftLabelText:[definition valueForKey:TK_VAS_LEFT_LABEL_KEY]];
    [self setMidLabelText:[definition valueForKey:TK_VAS_MID_LABEL_KEY]];
    [self setRightLabelText:[definition valueForKey:TK_VAS_RIGHT_LABEL_KEY]];
    [self setNumberOfTickMarks:[[definition valueForKey:TK_VAS_NUMBER_OF_TICK_MARKS_KEY] integerValue]];
    [self setSliderMinValue:[[definition valueForKey:TK_VAS_SLIDER_MIN_VALUE_KEY] doubleValue]];
    [self setSliderMaxValue:[[definition valueForKey:TK_VAS_SLIDER_MAX_VALUE_KEY] doubleValue]];
    [super loadPreferences];
}
-(void) resetInterface {
	[slider setIntegerValue:sliderMinValue];
	[button setEnabled:NO];
}
#pragma mark UI Actions
-(IBAction) sliderHasChanged:(id) sender {
	if(![button isEnabled]) {
		[button setEnabled:YES];
	}
}
-(IBAction) submitButton:(id) sender {
	[self userDidRespond:[slider integerValue]];
}
@end
