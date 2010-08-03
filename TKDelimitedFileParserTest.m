//
//  TKDelimitedFileParserTest.m
//  TKUtility
//
//  Created by tnesland on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TKDelimitedFileParserTest.h"

#define BUNDLE [NSBundle bundleWithIdentifier:@"com.yourcompany.TKUtilityTest"]
#define REGCSV [BUNDLE pathForResource:@"regular" ofType:@"csv"]
#define REGTAB [BUNDLE pathForResource:@"regular" ofType:@"tab"]
#define KEYCSV [BUNDLE pathForResource:@"keys" ofType:@"csv"]
#define KEYTAB [BUNDLE pathForResource:@"keys" ofType:@"tab"]
#define HEADER [BUNDLE pathForResource:@"headers" ofType:@"csv"]
#define BADHEADER [BUNDLE pathForResource:@"badheaders" ofType:@"csv"]
#define DEFAULT REGCSV
#define DEFAULT_REC_DELIM @"\n"
#define DEFAULT_FIELD_DELIM @","

@implementation TKDelimitedFileParserTest
@synthesize p;
-(void)setUp
{
  p = [[TKDelimitedFileParser parserWithFile:DEFAULT
                              usingEncoding:NSUTF8StringEncoding
                        withRecordDelimiter:DEFAULT_REC_DELIM
                         withFieldDelimiter:DEFAULT_FIELD_DELIM] retain];
}
-(void)testParserExists
{
  STAssertNotNil(p,@"Parser was not instantiated");
}
-(void)testAssertNoEmptyRecords
{
  for(NSUInteger i=0;i<[[p records]count];i++) {
    STAssertNotNil([p valueForFieldByIndex:0 ofRecordByIndex:i],@"Found empty record in parser");
  }
}
-(void)testCanReadTabDelimited
{
  [p release];
  p = [[TKDelimitedFileParser parserWithFile:REGTAB
                              usingEncoding:NSUTF8StringEncoding
                        withRecordDelimiter:DEFAULT_REC_DELIM
                          withFieldDelimiter:@"\t"] retain];
  STAssertNotNil(p,@"Tab delimited parser not instantiated");
  STAssertTrue([[p valueForFieldByIndex:0 ofRecordByIndex:0]isEqualToString:@"1"],
               @"Should be '1', but it is %@",[p valueForFieldByIndex:0 ofRecordByIndex:0]);
  STAssertTrue([[p valueForFieldByIndex:1 ofRecordByIndex:1]isEqualToString:@"Where am I?"],
               @"Should be 'Where am I?', but it is %@",[p valueForFieldByIndex:2 ofRecordByIndex:1]);
  STAssertTrue([[p valueForFieldByIndex:3 ofRecordByIndex:3]isEqualToString:@"butterface"],
               @"Should be 'butterface', but it is %@",[p valueForFieldByIndex:3 ofRecordByIndex:3]);
}
-(void)testCanReadKeyValues
{
  [p release];
  p = [[TKDelimitedFileParser parserWithFile:KEYCSV
                              usingEncoding:NSUTF8StringEncoding
                        withRecordDelimiter:DEFAULT_REC_DELIM
                          withFieldDelimiter:DEFAULT_FIELD_DELIM] retain];
  // test key-value before key-value is set
  STAssertNil([p valueForKey:@"id"],
              @"Parser should return nil when keys not set, but returned %@",
              [p valueForKey:@"id"]);
  // test expected values
  [p setIsKeyValueSet:YES];
  STAssertTrue([p isKeyValueSet]==YES,@"Parser was not successfully set to key-value");
  STAssertTrue([[p valueForKey:@"id"] isEqualToString:@"123456"],
               @"Value for id should be 123456, but it is %@",[p valueForKey:@"id"]);
  STAssertTrue([[p valueForKey:@"username"]isEqualToString:@"juser"],
               @"Value for username should be juser, but it is %@",[p valueForKey:@"username"]);
  STAssertTrue([[p valueForKey:@"email"]isEqualToString:@"juser@tester.com"],
               @"Value for email should be juser@tester.com, but it is %@",[p valueForKey:@"email"]);
  STAssertTrue([[p valueForKey:@"phone"]isEqualToString:@"1231231234"],
               @"Value for phone should be 1231231234, but it is %@",[p valueForKey:@"phone"]);
  // test bad key
  STAssertNil([p valueForKey:@"badkey"],@"Should return nil for bad key, returned %@",
              [p valueForKey:@"badkey"]);
  // test reset key-value false
  [p setIsKeyValueSet:NO];
  STAssertFalse([p isKeyValueSet],@"Did not reset key-value to false");
  STAssertNil([p valueForKey:@"id"],@"Should return nil after reset, returned %@",
              [p valueForKey:@"id"]);
}
-(void)testCanReadFieldsByHeaders
{
  [p release];
  p = [[TKDelimitedFileParser parserWithFile:HEADER
                              usingEncoding:NSUTF8StringEncoding
                        withRecordDelimiter:DEFAULT_REC_DELIM
                          withFieldDelimiter:DEFAULT_FIELD_DELIM] retain];
  // test that before field headers are setup, attempt by field key returns nil
  STAssertNil([p valueForFieldByKey:@"id" ofRecordByIndex:0],
              @"Should return nil when headers not setup, but returned %@",
              [p valueForFieldByKey:@"id" ofRecordByIndex:0]);
  // test that field headers can be setup
  [p setHasFieldsHeader:YES];
  STAssertTrue([p hasFieldsHeader]==YES,@"Parser did not successfully setup headers");
  // test of expected values
  STAssertTrue([[p valueForFieldByKey:@"id" ofRecordByIndex:0]isEqualToString:@"1"],
               @"Value for 'id' of record 0 should be '1', but it is: %@",
               [p valueForFieldByKey:@"id" ofRecordByIndex:0]);
  STAssertTrue([[p valueForFieldByKey:@"question" ofRecordByIndex:0]isEqualToString:@"How did I get here?"],
               @"Value for 'question' of record 0 should be 'How did I get here?', but it is: %@",
               [p valueForFieldByKey:@"question" ofRecordByIndex:0]);
  STAssertTrue([[p valueForFieldByKey:@"response" ofRecordByIndex:3]isEqualToString:@"18"],
               @"Value for 'response' of record 3 should be '18', but it is: %@",
               [p valueForFieldByKey:@"response" ofRecordByIndex:3]);
  STAssertTrue([[p valueForFieldByKey:@"note" ofRecordByIndex:3]isEqualToString:@"butterface"],
               @"Value for 'note' of record 3 should be 'butterface', but it is: %@",
               [p valueForFieldByKey:@"note" ofRecordByIndex:3]);
  // test that bad field returns nil
  STAssertNil([p valueForFieldByKey:@"badkey" ofRecordByIndex:0],
              @"Should return nil for badkey, but returned %@",
              [p valueForFieldByKey:@"badkey" ofRecordByIndex:0]);
  // test unset of field headers
  [p setHasFieldsHeader:NO];
  STAssertTrue([p hasFieldsHeader]==NO,@"Parser did not successfully tear down headers");
  STAssertTrue([[p valueForFieldByIndex:0 ofRecordByIndex:0]isEqualToString:@"id"],
               @"Parser did not successfully tear down headers");
}
-(void)testBadHeadersFormat // bad format means inconsistent number of fields
{
  [p release];
  p = [[TKDelimitedFileParser parserWithFile:BADHEADER
                              usingEncoding:NSUTF8StringEncoding
                        withRecordDelimiter:DEFAULT_REC_DELIM
                          withFieldDelimiter:DEFAULT_FIELD_DELIM] retain];
  [p setHasFieldsHeader:YES];
  STAssertFalse([p hasFieldsHeader],@"Should not set field headers with bad format");
}
-(void)testCountOfRecords
{
  // count of records for default file is 4
  STAssertTrue([[p records] count] == 4,@"Contains %d records", [[p records] count]);
}
-(void) tearDown
{
  [p release];
}
@end
