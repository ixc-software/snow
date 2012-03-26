//
//  DestinationsListWeBuyResults.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/25/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListWeBuyTesting;

@interface DestinationsListWeBuyResults : NSManagedObject

@property (nonatomic, retain) NSString * call_id;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * disconnect_cause;
@property (nonatomic, retain) NSNumber * disconnect_code;
@property (nonatomic, retain) NSString * dstnum;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSNumber * inpack;
@property (nonatomic, retain) NSString * log;
@property (nonatomic, retain) NSData * media_g729;
@property (nonatomic, retain) NSData * media_g729_ring;
@property (nonatomic, retain) NSData * media_ogg;
@property (nonatomic, retain) NSData * media_ogg_ring;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * outpack;
@property (nonatomic, retain) NSNumber * ringingOK;
@property (nonatomic, retain) NSNumber * srcnum;
@property (nonatomic, retain) NSNumber * tryingRinging;
@property (nonatomic, retain) NSNumber * ts_invite;
@property (nonatomic, retain) NSNumber * ts_ok;
@property (nonatomic, retain) NSNumber * ts_release;
@property (nonatomic, retain) NSNumber * ts_ringing;
@property (nonatomic, retain) NSNumber * ts_trying;
@property (nonatomic, retain) NSString * numberB;
@property (nonatomic, retain) NSNumber * inputPackets;
@property (nonatomic, retain) NSNumber * outputPackets;
@property (nonatomic, retain) NSDate * timeInvite;
@property (nonatomic, retain) NSDate * timeOk;
@property (nonatomic, retain) NSDate * timeRelease;
@property (nonatomic, retain) NSDate * timeRinging;
@property (nonatomic, retain) NSDate * timeTrying;
@property (nonatomic, retain) NSString * numberA;
@property (nonatomic, retain) NSData * ringMP3;
@property (nonatomic, retain) NSData * callMP3;
@property (nonatomic, retain) NSNumber * isFAS;
@property (nonatomic, retain) NSString * fasReason;
@property (nonatomic, retain) NSDate * timeSetup;
@property (nonatomic, retain) DestinationsListWeBuyTesting *destinationsListWeBuyTesting;

@end
