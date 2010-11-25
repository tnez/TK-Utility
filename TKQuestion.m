/***************************************************************
 
 TKQuestion.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKQuestion.h"


@implementation TKQuestion

@synthesize uid,text,leftScaleOverride,rightScaleOverride,additionalFields;

+(TKQuestion *)questionWithUid:(NSString *)_uid
                      withText:(NSString *)_text
{
  TKQuestion *newQuestion = [TKQuestion alloc];
  if([newQuestion initWithUid:_uid withText:_text])
  {
    return [newQuestion autorelease];
  }
  [newQuestion release];
  return nil;
}
+(TKQuestion *)questionWithUid: (NSString *)_uid
                      withText: (NSString *)_text
          withAdditionalFields: (NSArray *)_addFields
{
  TKQuestion *newQuestion = [TKQuestion alloc];
  if([newQuestion initWithUid:_uid
                     withText:_text
         withAdditionalFields:_addFields])
  {
    return [newQuestion autorelease];
  }
  [newQuestion release];
  return nil;
}
+(TKQuestion *)questionWithUid:(NSString *)_uid
                      withText:(NSString *)_text
              withLeftOverride:(NSString *)_leftScaleOverride
             withRightOverride:(NSString *)_rightScaleOverride
{
  TKQuestion *newQuestion = [TKQuestion alloc];
  if([newQuestion initWithUid:_uid
                     withText:_text
             withLeftOverride:_leftScaleOverride
            withRightOverride:_rightScaleOverride])
  {
    return [newQuestion autorelease];
  }
  [newQuestion release];
  return nil;
}

+(TKQuestion *)questionWithQuestion:(TKQuestion *)_question
{
  TKQuestion *newQuestion = [TKQuestion alloc];
  if([newQuestion initWithQuestion:_question])
  {
    return [newQuestion autorelease];
  }
  [newQuestion release];
  return nil;
}
-(TKQuestion *) initWithUid:(NSString *)_uid
                   withText:(NSString *)_text
{
  if(self=[super init])
  {
    uid = [_uid copy];
    text = [_text copy];
    leftScaleOverride = nil;
    rightScaleOverride = nil;
    return self;
  }
  return nil;
}


-(TKQuestion *) initWithUid:(NSString *)_uid
                   withText:(NSString *)_text
       withAdditionalFields:(NSArray *)_addFields
{
  if(self=[super init])
  {
    uid = [_uid copy];
    text = [_text copy];
    additionalFields = [_addFields copy];
    leftScaleOverride = nil;
    rightScaleOverride = nil;
    return self;
  }
  return nil;
}
-(TKQuestion *) initWithUid:(NSString *)_uid
                   withText:(NSString *)_text
           withLeftOverride:(NSString *)_leftScaleOverride
          withRightOverride:(NSString *)_rightScaleOverride
{
  if([self initWithUid:_uid withText:_text])
  {
    leftScaleOverride = [_leftScaleOverride copy];
    rightScaleOverride = [_rightScaleOverride copy];
    return self;
  }
  return nil;
}
-(TKQuestion *) initWithQuestion:(TKQuestion *)_question
{
  if(self=[super init])
  {
    uid = [[_question uid] copy];
    text = [[_question text] copy];
    leftScaleOverride = [[_question leftScaleOverride] copy];
    rightScaleOverride = [[_question rightScaleOverride] copy];
    return self;
  }
  return nil;
}
-(void)dealloc
{
  // release ivars
  [uid release];
  [text release];
  [leftScaleOverride release];
  [rightScaleOverride release];
  // super ->
  [super dealloc];
}
  
@end
