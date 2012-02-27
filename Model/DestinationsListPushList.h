//
//  DestinationsListPushList.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, CodesvsDestinationsList, DestinationDiscussion;

@interface DestinationsListPushList : NSManagedObject

@property (nonatomic, retain) NSNumber * acd;
@property (nonatomic, retain) NSNumber * asr;
@property (nonatomic, retain) NSNumber * callAttempts;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * minutesLenght;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * opened;
@property (nonatomic, retain) NSNumber * postInSalesChat;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * rowHeight;
@property (nonatomic, retain) NSString * specific;
@property (nonatomic, retain) Carrier *carrier;
@property (nonatomic, retain) NSSet *codesvsDestinationsList;
@property (nonatomic, retain) NSSet *destinationDiscussion;
@end

@interface DestinationsListPushList (CoreDataGeneratedAccessors)

- (void)addCodesvsDestinationsListObject:(CodesvsDestinationsList *)value;
- (void)removeCodesvsDestinationsListObject:(CodesvsDestinationsList *)value;
- (void)addCodesvsDestinationsList:(NSSet *)values;
- (void)removeCodesvsDestinationsList:(NSSet *)values;
- (void)addDestinationDiscussionObject:(DestinationDiscussion *)value;
- (void)removeDestinationDiscussionObject:(DestinationDiscussion *)value;
- (void)addDestinationDiscussion:(NSSet *)values;
- (void)removeDestinationDiscussion:(NSSet *)values;
@end
