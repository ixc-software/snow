//
//  DestinationsListPushList.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsListPushList.h"
#import "Carrier.h"
#import "CodesvsDestinationsList.h"
#import "DestinationDiscussion.h"


@implementation DestinationsListPushList

@dynamic acd;
@dynamic asr;
@dynamic callAttempts;
@dynamic country;
@dynamic creationDate;
@dynamic GUID;
@dynamic minutesLenght;
@dynamic modificationDate;
@dynamic opened;
@dynamic postInSalesChat;
@dynamic prefix;
@dynamic rate;
@dynamic rowHeight;
@dynamic specific;
@dynamic carrier;
@dynamic codesvsDestinationsList;
@dynamic destinationDiscussion;
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
