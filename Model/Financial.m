//
//  Financial.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "Financial.h"
#import "Carrier.h"
#import "InvoicesAndPayments.h"


@implementation Financial

@dynamic additionalInfo;
@dynamic balance;
@dynamic bankABA;
@dynamic bankAccountNumber;
@dynamic bankAddress;
@dynamic bankIBAN;
@dynamic bankName;
@dynamic bankSwift;
@dynamic creationDate;
@dynamic GUID;
@dynamic modificationDate;
@dynamic name;
@dynamic paymentTermsBillingPeriod;
@dynamic paymentTermsPaidAverageDelay;
@dynamic paymentTermsPaidPeriod;
@dynamic carrier;
@dynamic invoicesAndPayments;
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
