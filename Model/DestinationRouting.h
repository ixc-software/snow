//
//  DestinationRouting.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListForSale, DestinationsListWeBuy;

@interface DestinationRouting : NSManagedObject

@property (nonatomic, retain) NSNumber * ACDmax;
@property (nonatomic, retain) NSNumber * ACDmin;
@property (nonatomic, retain) NSNumber * ASRmax;
@property (nonatomic, retain) NSNumber * ASRmin;
@property (nonatomic, retain) NSString * carrier;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * lastUsedACD;
@property (nonatomic, retain) NSNumber * lastUsedASR;
@property (nonatomic, retain) NSNumber * lastUsedCallAttempts;
@property (nonatomic, retain) NSDate * lastUsedDate;
@property (nonatomic, retain) NSNumber * lastUsedMinutesLenght;
@property (nonatomic, retain) NSNumber * lastUsedProfit;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSDecimalNumber * priority;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * specific;
@property (nonatomic, retain) DestinationsListForSale *destinationsListForSale;
@property (nonatomic, retain) DestinationsListWeBuy *destinationsListWeBuy;

@end
