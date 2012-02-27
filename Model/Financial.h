//
//  Financial.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, InvoicesAndPayments;

@interface Financial : NSManagedObject

@property (nonatomic, retain) NSString * additionalInfo;
@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSString * bankABA;
@property (nonatomic, retain) NSString * bankAccountNumber;
@property (nonatomic, retain) NSString * bankAddress;
@property (nonatomic, retain) NSString * bankIBAN;
@property (nonatomic, retain) NSString * bankName;
@property (nonatomic, retain) NSString * bankSwift;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * paymentTermsBillingPeriod;
@property (nonatomic, retain) NSNumber * paymentTermsPaidAverageDelay;
@property (nonatomic, retain) NSNumber * paymentTermsPaidPeriod;
@property (nonatomic, retain) Carrier *carrier;
@property (nonatomic, retain) NSSet *invoicesAndPayments;
@end

@interface Financial (CoreDataGeneratedAccessors)

- (void)addInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)removeInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)addInvoicesAndPayments:(NSSet *)values;
- (void)removeInvoicesAndPayments:(NSSet *)values;
@end
