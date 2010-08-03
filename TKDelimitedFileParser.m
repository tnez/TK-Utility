/***************************************************************
 
 TKDelimitedFileParser.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKDelimitedFileParser.h"


@implementation TKDelimitedFileParser
@synthesize hasFieldsHeader, isKeyValueSet, records;
-(BOOL)canUseFirstColumnAsKey
{
  for(NSUInteger i=0;i<[records count];i++)
  {
    if([[records objectAtIndex:i] count] != 2) return NO;
  }
  return YES;
}
-(BOOL)canUseFirstRowAsFieldsHeader
{
  NSUInteger headerFieldCount = [[records objectAtIndex:0] count];
  for(NSUInteger i=1;i<[records count];i++)
  {
    if([[records objectAtIndex:i] count] != headerFieldCount) return NO;
  }
  return YES;
}
-(void)dealloc
{
  // release simple ivars
  [file release];
  [recordDelimiter release];
  [fieldDelimiter release];
  [charsToIgnore release];
  for(NSArray *rec in records)
  {
    [rec release];
  }
  [records release];
  if(hasFieldsHeader) [fieldnames release];
  [super dealloc];
}
-(BOOL)hasSuccessfullyReadFile
{
  // read entire file
  NSString *chunk = [[NSString alloc] initWithContentsOfFile:file
                                                    encoding:encoding
                                                       error:&error];
  // load record strings
  NSArray *recordstrings = [[NSArray alloc]
                              initWithArray:
                                [chunk componentsSeparatedByString:recordDelimiter]];
  // iterate through record strings and add each to record set as array
  for(NSUInteger i=0;i<[recordstrings count];i++)
  {
    // if the string is not empty ...
    if(![[recordstrings objectAtIndex:i] isEqualToString:@""]) {
      // ... add it to our records array
      [records addObject:[[NSArray alloc] initWithArray:
                          [[recordstrings objectAtIndex:i] componentsSeparatedByString:fieldDelimiter]]];
    }
  }
  [chunk release];
  [recordstrings release];
	if([[self records] count] > 0) {
		return YES; // indicate success
	} else { return NO; }
}
-(NSUInteger)indexForField:(NSString *)fieldKey // do not call unless hasFieldsHeader is TRUE
{
  // loop through field header array to find index of given key
  for(NSUInteger i=0;i<[fieldnames count];i++)
  {
    if([[[fieldnames objectAtIndex:i] stringByTrimmingCharactersInSet:charsToIgnore] isEqualToString:fieldKey])
    {
      return i;
    }
  }
  return [fieldnames count]; // return index out of range, will in turn cause a nil return in calling function
}
-(id)init
{
  if(self=[super init])
  {
    hasFieldsHeader = NO;
    isKeyValueSet = NO;
    charsToIgnore = [[NSCharacterSet
                      characterSetWithCharactersInString:TKDELIM_TEXT_QUALIFIERS] retain];
    records = [[NSMutableArray alloc] init];
    error = nil;    // error will be created if and when error occurs
    return self;
  }
  return nil;
}
-(id)initParserWithFile:(NSString *)_file
          usingEncoding:(NSStringEncoding)_encoding
    withRecordDelimiter:(NSString *)_rdelim
     withFieldDelimiter:(NSString *)_fdelim
{
  if([self init])
  {
    file = [[_file stringByStandardizingPath] copy];
    encoding = _encoding;
    recordDelimiter = [_rdelim copy];
    fieldDelimiter = [_fdelim copy];
    if([self hasSuccessfullyReadFile]) return self;
  }
  return nil;
}

+(id)parserWithFile:(NSString *)_file
withRecordDelimiter:(NSString *)_rdelim
 withFieldDelimiter:(NSString *)_fdelim {
	return [TKDelimitedFileParser parserWithFile:_file
																 usingEncoding:TKDELIM_DEFAULT_ENCODING
													 withRecordDelimiter:_rdelim
														withFieldDelimiter:_fdelim];
}	

+(id)parserWithFile:(NSString *)_file
      usingEncoding:(NSStringEncoding)_encoding
withRecordDelimiter:(NSString *)_rdelim
 withFieldDelimiter:(NSString *)_fdelim
{
  TKDelimitedFileParser *newParser = [TKDelimitedFileParser alloc];
  if([newParser initParserWithFile:_file
                     usingEncoding:_encoding
               withRecordDelimiter:_rdelim
                withFieldDelimiter:_fdelim])
  {
    return [newParser autorelease];
  }
  else
  {
    [newParser release];
  }
  return nil;
}
-(NSArray *)recordByIndex:(NSUInteger)index
{
  if(index < [records count]) return [records objectAtIndex:index];
  // else . . .
  return nil;
}
-(NSArray *)recordByKey:(NSString *)key
{
  NSString *mykey = [key copy];   // copy to prevent alteration by sender
  for(NSUInteger i = 0;i<[records count];i++)
  {
    // if we find a match, give it back
    if([mykey isEqualToString:[[[records objectAtIndex:i] objectAtIndex:0] stringByTrimmingCharactersInSet:charsToIgnore]])
    {
      [mykey release];
      return [records objectAtIndex:i];
    }
  }
  // if we don't match, give back nil
  [mykey release];
  return nil;
}
-(void)setHasFieldsHeader:(BOOL)yup
{
  if(yup) // if we are trying to set "YES"...
  {
    // if we have already done this, there is nothing to do
    if(hasFieldsHeader) return;
    // otherwise, check that first row contains valid header...
    if([self canUseFirstRowAsFieldsHeader])
    {
      // turn first record into fields header array
      fieldnames = [[NSArray alloc] initWithArray:[records objectAtIndex:0]];
      // remove fields header array from records array
      [records removeObjectAtIndex:0];
      // set flag
      hasFieldsHeader = YES;
      return;
    }
    else // first row not valid for header
    {
      // set error, flag and return
      error = [[NSError errorWithDomain:@"TKDelimitedFileParser|setHasFieldsHeader(invalid header format)"
                                   code:401
                               userInfo:nil] retain];
      hasFieldsHeader = NO;
      return;
    }
  }
  else // attempting to set "NO"
  {
    // if currently no, then nothing to do
    if(!hasFieldsHeader) return;
    // else we need to remove header array and turn back into first record
    [records insertObject:[fieldnames copy] atIndex:0];
    [fieldnames release];
    hasFieldsHeader = NO;
  }
}
-(void)setIsKeyValueSet:(BOOL)yup
{
  isKeyValueSet = yup && [self canUseFirstColumnAsKey];
}
-(NSString *)valueForFieldByKey:(NSString *)fieldKey
                       ofRecord:(id)record
{
  if(hasFieldsHeader) {
    NSUInteger idx = [self indexForField:fieldKey];
    if(idx<[record count]) {
      return [[record objectAtIndex:idx] stringByTrimmingCharactersInSet:charsToIgnore];
    }
  }
  return nil; // if object not found
}
-(NSString *)valueForFieldByKey:(NSString *)fieldKey
                ofRecordByIndex:(NSUInteger)recordIndex
{
  return [self valueForFieldByKey:fieldKey ofRecord:[self recordByIndex:recordIndex]];
}
-(NSString *)valueForFieldByKey:(NSString *)fieldKey
                  ofRecordByKey:(NSString *)recordKey
{
  return [self valueForFieldByKey:fieldKey ofRecord:[self recordByKey:recordKey]];
}
-(NSString *)valueForFieldByIndex:(NSUInteger)fieldIndex
                         ofRecord:(id)record
{
  // if field index is valid . . .
  if(fieldIndex < [record count])
  {
    return [[record objectAtIndex:fieldIndex] stringByTrimmingCharactersInSet:charsToIgnore];
  }
  // else . . .
  return nil; // object not found
}
-(NSString *)valueForFieldByIndex:(NSUInteger)fieldIndex
                  ofRecordByIndex:(NSUInteger)recordIndex
{
  return [self valueForFieldByIndex:fieldIndex ofRecord:[self recordByIndex:recordIndex]];
}
-(NSString *)valueForFieldByIndex:(NSUInteger)fieldIndex
                    ofRecordByKey:(NSString *)recordKey
{
  return [self valueForFieldByIndex:fieldIndex ofRecord:[self recordByKey:recordKey]];
}
-(NSString *)valueForKey:(NSString *)key
{
  // if not valid key-value format, exit
  if(!isKeyValueSet) return nil;
  // else, valid - proceed
  return [self valueForFieldByIndex:1 ofRecordByKey:key];
}
@end
