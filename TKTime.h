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

TKTime new_time_marker (NSUInteger sec, NSUInteger microsec);
TKTime current_time_marker ();
TKTime difference (TKTime startMarker, TKTime stopMarker);
TKTime time_since (TKTime startMarker);
