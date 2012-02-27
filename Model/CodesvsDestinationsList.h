//
//  CodesvsDestinationsList.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListForSale, DestinationsListPushList, DestinationsListTargets, DestinationsListWeBuy;

@interface CodesvsDestinationsList : NSManagedObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSDate * externalChangedDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * internalChangedDate;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * originalCode;
@property (nonatomic, retain) NSNumber * peerID;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * rateSheetID;
@property (nonatomic, retain) NSString * rateSheetName;
@property (nonatomic, retain) NSString * specific;
@property (nonatomic, retain) DestinationsListForSale *destinationsListForSale;
@property (nonatomic, retain) DestinationsListPushList *destinationsListPushList;
@property (nonatomic, retain) DestinationsListTargets *destinationsListTargets;
@property (nonatomic, retain) DestinationsListWeBuy *destinationsListWeBuy;

@end
