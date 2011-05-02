/***************************************************************
 
 TKTime.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import <Cocoa/Cocoa.h>
#import <sys/time.h>

typedef struct {
  NSUInteger seconds;
  NSUInteger microseconds;
} TKTime;

/** 
    A new time value using the given second and microsecond values.
 */
TKTime new_time_marker (NSUInteger sec, NSUInteger microsec);

/** 
    A new time marker using the current second and mircrosecond values.
 */
TKTime current_time_marker ();

/** 
    The difference of two time markers as a time.
 */
TKTime difference (TKTime startMarker, TKTime stopMarker);

/** 
    The difference between the current time and a previous time marker
    as a time marker.
 */
TKTime time_since (TKTime startMarker);

/** 
    The microsecond value for a given time.
 */
NSUInteger time_as_microseconds (TKTime timeMarker);

/** 
    A new time marker created using the given microseconds value.
*/
TKTime time_from_microseconds (NSUInteger usecs);

/** 
    The millisecond value for a given time marker.
*/
NSUInteger time_as_milliseconds (TKTime timeMarker);

/** 
    A new time marker created from the given milliseconds value.
*/
TKTime time_from_milliseconds (NSUInteger msecs);
