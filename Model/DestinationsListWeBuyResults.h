//
//  DestinationsListWeBuyResults.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
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
@property (nonatomic, retain) DestinationsListWeBuyTesting *destinationsListWeBuyTesting;

@end
