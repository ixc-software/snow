//
//  CurrentCompany.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CurrentCompany.h"
#import "CompanyAccounts.h"
#import "CompanyStuff.h"
#import "Currency.h"
#import "DatabaseConnections.h"
#import "OperationNecessaryToApprove.h"


@implementation CurrentCompany

@dynamic additionalInformation;
@dynamic address;
@dynamic carriersCount;
@dynamic companyAdminGUID;
@dynamic creationDate;
@dynamic destinationsForSaleCount;
@dynamic destinationsPushListCount;
@dynamic destinationsTargetsCount;
@dynamic destinationsWeBuyCount;
@dynamic GUID;
@dynamic isRegistrationDone;
@dynamic isRegistrationProcessed;
@dynamic isVisibleForCommunity;
@dynamic localPhoneList;
@dynamic logoURL;
@dynamic modificationDate;
@dynamic name;
@dynamic ratesEmail;
@dynamic stuffCount;
@dynamic url;
@dynamic companyAccounts;
@dynamic companyStuff;
@dynamic currency;
@dynamic databaseConnections;
@dynamic operationNecessaryToApprove;
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
