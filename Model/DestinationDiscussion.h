//
//  DestinationDiscussion.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListForSale, DestinationsListPushList, DestinationsListTargets, DestinationsListWeBuy;

@interface DestinationDiscussion : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * writerName;
@property (nonatomic, retain) DestinationsListForSale *destinationsListForSale;
@property (nonatomic, retain) DestinationsListPushList *destinationsListPushList;
@property (nonatomic, retain) DestinationsListTargets *destinationsListTargets;
@property (nonatomic, retain) DestinationsListWeBuy *destinationsListWeBuy;

@end
