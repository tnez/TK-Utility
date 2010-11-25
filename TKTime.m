/***************************************************************
 
 TKTime.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100803 - tn
 
 ***************************************************************/


#import "TKTime.h"

TKTime new_time_marker (NSUInteger sec, NSUInteger microsec) {
  TKTime newMarker;
  newMarker.seconds = sec;
  newMarker.microseconds = microsec;
  return newMarker;
}

TKTime current_time_marker () {
  TKTime newMarker;
  struct timeval now;
	gettimeofday(&now, NULL);
	newMarker.seconds = now.tv_sec;
	newMarker.microseconds = now.tv_usec;
  return newMarker;
}

TKTime difference (TKTime startMarker, TKTime stopMarker) {
  if(stopMarker.microseconds<startMarker.microseconds) {
    return new_time_marker (stopMarker.seconds-startMarker.seconds-1,
                            1000000+stopMarker.microseconds-startMarker.microseconds);
  } else {
    return new_time_marker (stopMarker.seconds-startMarker.seconds,
                            stopMarker.microseconds-startMarker.microseconds);
  }
}

TKTime time_since (TKTime startMarker) {
  return difference(startMarker, current_time_marker());
}

NSUInteger time_as_microseconds (TKTime marker) {
    return marker.seconds * 1000000 + marker.microseconds;
}

TKTime time_from_microseconds (NSUInteger usecs) {
    return new_time_marker(usecs / 1000000, usecs % 1000000);
}

NSUInteger time_as_milliseconds (TKTime marker) {
    return marker.seconds * 1000 + marker.microseconds / 1000;
}

TKTime time_from_milliseconds (NSUInteger msecs) {
  return new_time_marker(msecs / 1000, (msecs % 1000) * 1000);
}
