//
//  DestinationDiscussion.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationDiscussion.h"
#import "DestinationsListForSale.h"
#import "DestinationsListPushList.h"
#import "DestinationsListTargets.h"
#import "DestinationsListWeBuy.h"


@implementation DestinationDiscussion

@dynamic creationDate;
@dynamic desc;
@dynamic GUID;
@dynamic modificationDate;
@dynamic writerName;
@dynamic destinationsListForSale;
@dynamic destinationsListPushList;
@dynamic destinationsListTargets;
@dynamic destinationsListWeBuy;
- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"GUID"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"GUID"];
    [self didChangeValueForKey:@"GUID"];
    
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveValue:now forKey:@"creationDate"];
    [self didChangeValueForKey:@"creationDate"];
    
    [self willChangeValueForKey:@"modificationDate"];
    [self setPrimitiveValue:now forKey:@"modificationDate"];
    [self didChangeValueForKey:@"modificationDate"];
}

-(void)willSave {
    NSDate *now = [NSDate date];
    if ([self isUpdated]) {
        
        
        if (self.modificationDate == nil || [now timeIntervalSinceDate:self.modificationDate] > 1.0) {
            self.modificationDate = now;
        }
    }
}

@end
