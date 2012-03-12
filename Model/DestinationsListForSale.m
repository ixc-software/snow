//
//  DestinationsListForSale.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsListForSale.h"
#import "Carrier.h"
#import "CodesvsDestinationsList.h"
#import "DestinationDiscussion.h"
#import "DestinationPerHourStat.h"
#import "DestinationRouting.h"


@implementation DestinationsListForSale

@dynamic changeDate;
@dynamic country;
@dynamic creationDate;
@dynamic enabled;
@dynamic GUID;
@dynamic ipAddressesList;
@dynamic lastUsedACD;
@dynamic lastUsedASR;
@dynamic lastUsedCallAttempts;
@dynamic lastUsedDate;
@dynamic lastUsedIncome;
@dynamic lastUsedMinutesLenght;
@dynamic lastUsedProfit;
@dynamic modificationDate;
@dynamic postInSalesChat;
@dynamic prefix;
@dynamic rate;
@dynamic rateSheet;
@dynamic rateSheetID;
@dynamic specific;
@dynamic carrier;
@dynamic codesvsDestinationsList;
@dynamic destinationDiscussion;
@dynamic destinationPerHourStat;
@dynamic destinationRouting;
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

- (void)setLastUsedMinutesLenght:(NSNumber *)lastUsedMinutesLenght {
    
    [self willChangeValueForKey:@"lastUsedMinutesLenght"];
    [self setPrimitiveValue:lastUsedMinutesLenght forKey:@"lastUsedMinutesLenght"];
    
    [self willChangeValueForKey:@"lastUsedIncome"];
    NSNumber *expenses = [NSNumber numberWithDouble:[lastUsedMinutesLenght doubleValue] * [self.rate doubleValue]];
    [self setPrimitiveValue:expenses forKey:@"lastUsedIncome"];
    [self didChangeValueForKey:@"lastUsedIncome"];
    
    
    [self didChangeValueForKey:@"lastUsedMinutesLenght"];
    
}

- (void)setRate:(NSNumber *)rate {
    
    [self willChangeValueForKey:@"rate"];
    [self setPrimitiveValue:rate forKey:@"rate"];
    
    [self willChangeValueForKey:@"lastUsedIncome"];
    NSNumber *expenses = [NSNumber numberWithDouble:[self.lastUsedMinutesLenght doubleValue] * [rate doubleValue]];
    [self setPrimitiveValue:expenses forKey:@"lastUsedIncome"];
    [self didChangeValueForKey:@"lastUsedIncome"];
    
    [self didChangeValueForKey:@"rate"];
    
}

//-(void)willSave {
//    NSDate *now = [NSDate date];
//    if ([self isUpdated]) {
//        
//        
//        if (self.modificationDate == nil || [now timeIntervalSinceDate:self.modificationDate] > 1.0) {
//            self.modificationDate = now;
//        }
//    }
//}

@end
