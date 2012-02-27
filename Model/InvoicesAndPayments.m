//
//  InvoicesAndPayments.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "InvoicesAndPayments.h"
#import "CompanyAccounts.h"
#import "CompanyStuff.h"
#import "Currency.h"
#import "Financial.h"


@implementation InvoicesAndPayments

@dynamic amountCarrierSide;
@dynamic amountConfirmed;
@dynamic amountOurSide;
@dynamic creationDate;
@dynamic date;
@dynamic details;
@dynamic externalID;
@dynamic GUID;
@dynamic isInvoice;
@dynamic isReceived;
@dynamic modificationDate;
@dynamic number;
@dynamic pathToFile;
@dynamic paymentDate;
@dynamic usagePeriodFinish;
@dynamic usagePeriodStart;
@dynamic companyAccounts;
@dynamic companyStuff;
@dynamic currency;
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
