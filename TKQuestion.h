/***************************************************************
 
 TKQuestion.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>

@interface TKQuestion : NSObject {
  NSString *uid;               // each question should have a id
                               // unique to the set
  NSString *text;              // question text
  NSString *leftScaleOverride; // optional, if exists overrides
                               // default left slider prompt
  NSString *rightScaleOverride;// optional, if exists overrides
                               // default right slider prompt
}

@property(readonly) NSString *uid;
@property(readonly) NSString *text;
@property(readonly) NSString *leftScaleOverride;
@property(readonly) NSString *rightScaleOverride;

//
// questionWithUid:withText:
// Standard way to instantiate a question providing the
// unique id and question text
+(TKQuestion *) questionWithUid:(NSString *)_uid
                       withText:(NSString *)_text;
-(TKQuestion *) initWithUid:(NSString *)_uid
                   withText:(NSString *)_text;
//
// questionWithUid:withText:withLeftOverride:withRightOverride:
// Way to instantiate a question that will have a different
// left and right prompt than the rest of the question set
+(TKQuestion *) questionWithUid:(NSString *)_uid
                       withText:(NSString *)_text
               withLeftOverride:(NSString *)_leftScaleOverride
              withRightOverride:(NSString *)_rightScaleOverride;
-(TKQuestion *) initWithUid:(NSString *)_uid
                   withText:(NSString *)_text
           withLeftOverride:(NSString *)_leftScaleOverride
          withRightOverride:(NSString *)_rightScaleOverride;
//
// questionWithQuestion:
// Way to copy an existing question - this may be usefull if a
// question is intended to be repeatedly asked, but only a fixed
// number of times.
+(TKQuestion *) questionWithQuestion:(TKQuestion *)_question;
-(TKQuestion *) initWithQuestion:(TKQuestion *)_question;

@end
