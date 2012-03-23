//
//  Carrier.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "Carrier.h"
#import "CarrierStuff.h"
#import "CompanyStuff.h"
#import "DestinationsListForSale.h"
#import "DestinationsListPushList.h"
#import "DestinationsListTargets.h"
#import "DestinationsListWeBuy.h"
#import "Financial.h"


@implementation Carrier

@dynamic address;
@dynamic creationDate;
@dynamic emailList;
@dynamic financialRate;
@dynamic GUID;
@dynamic latestUpdateTime;
@dynamic modificationDate;
@dynamic name;
@dynamic phoneList;
@dynamic ratesEmail;
@dynamic url;
@dynamic externalID;
@dynamic carrierStuff;
@dynamic companyStuff;
@dynamic destinationsListForSale;
@dynamic destinationsListPushList;
@dynamic destinationsListTargets;
@dynamic destinationsListWeBuy;
@dynamic financial;
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
