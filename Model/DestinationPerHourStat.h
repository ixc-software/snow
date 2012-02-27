//
//  DestinationPerHourStat.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListForSale, DestinationsListWeBuy;

@interface DestinationPerHourStat : NSManagedObject

@property (nonatomic, retain) NSNumber * acd;
@property (nonatomic, retain) NSNumber * asr;
@property (nonatomic, retain) NSNumber * callAttempts;
@property (nonatomic, retain) NSNumber * cashflow;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * externalDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * minutesLenght;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * profit;
@property (nonatomic, retain) DestinationsListForSale *destinationsListForSale;
@property (nonatomic, retain) DestinationsListWeBuy *destinationsListWeBuy;

@end
