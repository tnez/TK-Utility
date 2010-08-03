/***************************************************************
 
 TKNotificationQueueItem.m
 TKUtility
 
 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/

#import "TKNotificationQueueItem.h"


@implementation TKNotificationQueueItem
@synthesize notification,secondsToRun,microsecondsToRun;

- (NSComparisonResult)compare:(TKNotificationQueueItem *)queueItem{
	if([self secondsToRun] < [queueItem secondsToRun]){
		return NSOrderedAscending;
	}else if([self secondsToRun] == [queueItem secondsToRun]){
		if([self microsecondsToRun] < [queueItem microsecondsToRun]){
			return NSOrderedAscending;
		}else if([self microsecondsToRun] == [queueItem microsecondsToRun]){
			return NSOrderedSame;
		}else{
			return NSOrderedDescending;
		}
	}else{
		return NSOrderedDescending;
	}
}
@end
