/***************************************************************
 
 TKTimer.m
 TKUtility
 
 Author: Scott Southerland
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKTimer.h"
#import "TKNotificationQueueItem.h"
#import <sys/time.h>


@implementation TKTimer

@synthesize microseconds,seconds,startTimeSeconds,startTimeMicroSeconds,continueTimer,notificationQueue;

+ (TKTimer *)appTimer
{
  static TKTimer *sharedInstance;

  @synchronized(self)
    {
      if (sharedInstance == NULL){
        sharedInstance = [[self alloc] init];
      }
    }
  return(sharedInstance);
}

-(id)init{
  if([super init]){
    seconds=0;
    microseconds=0;
    struct timeval now;
    gettimeofday(&now, NULL);
    startTimeSeconds=now.tv_sec;
    startTimeMicroSeconds=now.tv_usec;
    continueTimer=YES;
    notificationQueue = [[NSMutableArray alloc] init];
    return self;
  }
  return nil;
}
-(void)mainTimeLoop{
  struct timeval now;
  struct timespec ts;
  ts.tv_sec = 0;
  //Theoretically will run at most every microsecond, but generally runs every 20 to 50 microseconds
  ts.tv_nsec = 1000;

	while(continueTimer){
		@synchronized(self){
			gettimeofday(&now, NULL);
			NSUInteger tempSeconds=now.tv_sec;
			NSUInteger tempMicroSeconds=now.tv_usec;
			seconds=(tempSeconds-startTimeSeconds);
			if(tempMicroSeconds > startTimeMicroSeconds){
				microseconds=(tempMicroSeconds-startTimeMicroSeconds);
			}else{
				microseconds=(tempMicroSeconds+1000000-startTimeMicroSeconds);
				seconds--;
			}

			BOOL keepSearching=YES;
			while([notificationQueue count]>0&&keepSearching){
				TKNotificationQueueItem * queueItem =[notificationQueue objectAtIndex:0];
				BOOL shouldRemove=NO;
				if([queueItem secondsToRun] < seconds){
					shouldRemove=YES;
				}else if([queueItem secondsToRun]==seconds && [queueItem microsecondsToRun] <= microseconds){
					shouldRemove=YES;
				}
				if(shouldRemove){
					//printf(" Current Seconds :%u microseconds:%u    Event Seconds; %u microseconds: %u \n",seconds,microseconds,[queueItem secondsToRun],[queueItem microsecondsToRun]);
					NSNotificationCenter * center=[NSNotificationCenter defaultCenter];
					NSNotification * note = [queueItem notification];
					[center postNotification:note];
					[notificationQueue removeObjectAtIndex:0];
				}else{
					keepSearching=NO;
				}
			}
		}
        nanosleep (&ts, NULL);
	}

}
+(void)spawnAndBeginTimer:(id)param{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  TKTimer * timer=[TKTimer appTimer];
  [timer mainTimeLoop];

  [pool release];

}
-(void)registerEventWithNotification:(NSNotification *) notification inSeconds:(NSUInteger) secondsTilRun microSeconds:(NSUInteger)microsecondsTilRun{
	@synchronized(self){
		TKNotificationQueueItem * queueItem =[[TKNotificationQueueItem alloc] init];
		[queueItem setNotification:notification];
		NSUInteger secondToRun=seconds+secondsTilRun;

		//printf("Microseconds: %u \n",[self microseconds]);

		NSUInteger microsecondToRun=microseconds+microsecondsTilRun;

		//printf("ORIGINAL secondToRun :%u microsecondToRun:%u \n",secondToRun,microsecondToRun);

		while(microsecondToRun>(1000000)){
			microsecondToRun-=(1000000);
			secondToRun++;
		}
		//printf("secondToRun :%u microsecondToRun:%u \n\n",secondToRun,microsecondToRun);
		[queueItem setSecondsToRun:secondToRun];
		[queueItem setMicrosecondsToRun:microsecondToRun];
		[notificationQueue addObject:queueItem];
		[notificationQueue sortUsingSelector:@selector(compare:)];
	}
}

@end
