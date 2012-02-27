//
//  DestinationsListWeBuy.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsListWeBuy.h"
#import "Carrier.h"
#import "CodesvsDestinationsList.h"
#import "DestinationDiscussion.h"
#import "DestinationPerHourStat.h"
#import "DestinationRouting.h"
#import "DestinationsListWeBuyTesting.h"


@implementation DestinationsListWeBuy

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
@dynamic lastUsedExpenses;
@dynamic lastUsedMinutesLenght;
@dynamic lastUsedProfit;
@dynamic modificationDate;
@dynamic postInSalesChat;
@dynamic prefix;
@dynamic rate;
@dynamic rateSheet;
@dynamic rateSheetID;
@dynamic selectionTestingResult;
@dynamic specific;
@dynamic testingRestultInfo;
@dynamic testingResult;
@dynamic carrier;
@dynamic codesvsDestinationsList;
@dynamic destinationDiscussion;
@dynamic destinationPerHourStat;
@dynamic destinationRouting;
@dynamic destinationsListWeBuyTesting;
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
