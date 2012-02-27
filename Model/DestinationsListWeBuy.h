//
//  DestinationsListWeBuy.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, CodesvsDestinationsList, DestinationDiscussion, DestinationPerHourStat, DestinationRouting, DestinationsListWeBuyTesting;

@interface DestinationsListWeBuy : NSManagedObject

@property (nonatomic, retain) NSDate * changeDate;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSString * ipAddressesList;
@property (nonatomic, retain) NSNumber * lastUsedACD;
@property (nonatomic, retain) NSNumber * lastUsedASR;
@property (nonatomic, retain) NSNumber * lastUsedCallAttempts;
@property (nonatomic, retain) NSDate * lastUsedDate;
@property (nonatomic, retain) NSNumber * lastUsedExpenses;
@property (nonatomic, retain) NSNumber * lastUsedMinutesLenght;
@property (nonatomic, retain) NSNumber * lastUsedProfit;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * postInSalesChat;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * rateSheet;
@property (nonatomic, retain) NSString * rateSheetID;
@property (nonatomic, retain) NSNumber * selectionTestingResult;
@property (nonatomic, retain) NSString * specific;
@property (nonatomic, retain) NSString * testingRestultInfo;
@property (nonatomic, retain) id testingResult;
@property (nonatomic, retain) Carrier *carrier;
@property (nonatomic, retain) NSSet *codesvsDestinationsList;
@property (nonatomic, retain) NSSet *destinationDiscussion;
@property (nonatomic, retain) NSSet *destinationPerHourStat;
@property (nonatomic, retain) DestinationRouting *destinationRouting;
@property (nonatomic, retain) NSSet *destinationsListWeBuyTesting;
@end

@interface DestinationsListWeBuy (CoreDataGeneratedAccessors)

- (void)addCodesvsDestinationsListObject:(CodesvsDestinationsList *)value;
- (void)removeCodesvsDestinationsListObject:(CodesvsDestinationsList *)value;
- (void)addCodesvsDestinationsList:(NSSet *)values;
- (void)removeCodesvsDestinationsList:(NSSet *)values;
- (void)addDestinationDiscussionObject:(DestinationDiscussion *)value;
- (void)removeDestinationDiscussionObject:(DestinationDiscussion *)value;
- (void)addDestinationDiscussion:(NSSet *)values;
- (void)removeDestinationDiscussion:(NSSet *)values;
- (void)addDestinationPerHourStatObject:(DestinationPerHourStat *)value;
- (void)removeDestinationPerHourStatObject:(DestinationPerHourStat *)value;
- (void)addDestinationPerHourStat:(NSSet *)values;
- (void)removeDestinationPerHourStat:(NSSet *)values;
- (void)addDestinationsListWeBuyTestingObject:(DestinationsListWeBuyTesting *)value;
- (void)removeDestinationsListWeBuyTestingObject:(DestinationsListWeBuyTesting *)value;
- (void)addDestinationsListWeBuyTesting:(NSSet *)values;
- (void)removeDestinationsListWeBuyTesting:(NSSet *)values;
@end
