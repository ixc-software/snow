//
//  DestinationRouting.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationRouting.h"
#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"


@implementation DestinationRouting

@dynamic ACDmax;
@dynamic ACDmin;
@dynamic ASRmax;
@dynamic ASRmin;
@dynamic carrier;
@dynamic creationDate;
@dynamic desc;
@dynamic GUID;
@dynamic lastUsedACD;
@dynamic lastUsedASR;
@dynamic lastUsedCallAttempts;
@dynamic lastUsedDate;
@dynamic lastUsedMinutesLenght;
@dynamic lastUsedProfit;
@dynamic modificationDate;
@dynamic prefix;
@dynamic priority;
@dynamic rate;
@dynamic specific;
@dynamic destinationsListForSale;
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
