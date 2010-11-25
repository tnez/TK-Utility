/***************************************************************
 
 TKQuestionSet.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKQuestionSet.h"

@implementation TKQuestionSet

@synthesize uid,errorDescription,accessMethod;

+(id) questionSetFromFile:(NSString *)_fullpath usingAccessMethod:(NSUInteger)_accessMethod
{
  TKQuestionSet *newQuestionSet = [TKQuestionSet alloc];
  if([newQuestionSet initFromFile:_fullpath
                usingAccessMethod:_accessMethod])
  {
    return [newQuestionSet autorelease];
  }
  [newQuestionSet release];
  return nil;
}

-(id) initFromFile:(NSString *)_fullpath usingAccessMethod:(NSUInteger)_accessMethod
{
  if(self=[super init])
  {
      fullPathToFile = [[_fullpath stringByStandardizingPath] retain];
      accessMethod = _accessMethod;
      questions = [[NSMutableArray alloc] init];
      if([self questionsHaveLoaded]) { return self; }
  }
  return nil;
}

-(BOOL)isEmpty
{
  return [questions count] == 0;
}

-(BOOL)isValidQuestion: (NSArray *)_question {
  // for now we are only going to check that this
  // array has the min two fields expected
  return [_question count] >= 2;
}
  
-(id)nextQuestion
{
  if(![self isEmpty])
  {
  switch (accessMethod)
    {
    case TKQuestionSetSequentialAccess:
      return [self nextSequentialQuestion];
    case TKQuestionSetRandomNoRepeat:
      return [self nextRandomQuestionNoRepeat];
    case TKQuestionSetRandomWithRepeat:
      return [self nextRandomQuestionWithRepeat];
    default:
      errorDescription = @"Current parameter for AccessMethod is invalid";
      return nil;
    }
  }
  else // TKQuestionSet is empty!
  {
    errorDescription = @"Tried to access question from empty question set";
  }
  return nil;
}

/* 
 Description: Add a new question to the question set
 Return: ptr to the new question
*/
-(id)addQuestion:(TKQuestion *)newQuestion
{
	[questions addObject:newQuestion];
  return newQuestion;
}

-(NSInteger) count { // returns current count of question set
	return [questions count];
}

-(BOOL) questionsHaveLoaded {
	TKDelimitedFileParser *parser = 
  [[TKDelimitedFileParser parserWithFile:fullPathToFile
                           usingEncoding:DEFAULT_ENCODING
                     withRecordDelimiter:DEFAULT_RECORD_DELIM
                      withFieldDelimiter:DEFAULT_FIELD_DELIM] retain];
	// if question file was parsed successfully...
	if(parser) {
		// for each record in set . . .
		for(NSArray *rec in [parser records]) {
      // if this record is not a valid question...
      if(![self isValidQuestion:rec]) {
        // break from reading and return error
        return NO;
      }
			// . . . create new question
			// question fields as follows: id - text - add. fields (variable)
      // if the question has additional fields...
      if([rec count]>2) {
        // make a new question w/ add. fields
        [self addQuestion:
         [TKQuestion questionWithUid:[rec objectAtIndex:0]
                            withText:[rec objectAtIndex:1]
                withAdditionalFields:
          [rec subarrayWithRange:NSMakeRange(2,[rec count]-2)]]];
      } else {
        // make a new question w/ no add. fields
        [self addQuestion:
         [TKQuestion questionWithUid:[rec objectAtIndex:0]
                            withText:[rec objectAtIndex:1]]];
      }
		}
		// release parser and retur
		[parser release]; return YES;
	} else { return NO; }
}

-(TKQuestion *)nextSequentialQuestion
{
  id theQuestion = [[questions objectAtIndex:0] retain];
  [questions removeObjectAtIndex:0];
  return [theQuestion autorelease];
}

-(TKQuestion *)nextRandomQuestionNoRepeat
{
  NSUInteger pick = arc4random() % [questions count];
  id theQuestion = [[questions objectAtIndex:pick] retain];
  [questions removeObjectAtIndex:pick];
  return [theQuestion autorelease];
}

-(TKQuestion *)nextRandomQuestionWithRepeat
{
  NSUInteger pick = arc4random() % [questions count];
  return [questions objectAtIndex:pick];
}

-(NSString *)cleanPath:(NSString *)aPath
{
  return [aPath stringByStandardizingPath];
}

-(void)dealloc
{
  // release ivars
  [uid release];
  [errorDescription release];
  // super ->
  [super dealloc];
}

-(id) questionWithId:(NSString *) questionId {
	for(TKQuestion *q in questions) {
		if([[q uid] isEqualToString:questionId]) { return q; }
	} return nil;
}

-(void) removeQuestionWithId:(NSString *) questionId {
	[questions removeObject:[self questionWithId: questionId]];
}
	
@end

