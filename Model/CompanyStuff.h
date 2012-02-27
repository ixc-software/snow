//
//  CompanyStuff.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, CurrentCompany, InvoicesAndPayments;

@interface CompanyStuff : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSData * deviceToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fromIP;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * isCompanyAdmin;
@property (nonatomic, retain) NSNumber * isRegistrationDone;
@property (nonatomic, retain) NSNumber * isRegistrationProcessed;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * toIP;
@property (nonatomic, retain) NSData * transactionReceipt;
@property (nonatomic, retain) NSSet *carrier;
@property (nonatomic, retain) CurrentCompany *currentCompany;
@property (nonatomic, retain) NSSet *invoicesAndPayments;
@end

@interface CompanyStuff (CoreDataGeneratedAccessors)

- (void)addCarrierObject:(Carrier *)value;
- (void)removeCarrierObject:(Carrier *)value;
- (void)addCarrier:(NSSet *)values;
- (void)removeCarrier:(NSSet *)values;
- (void)addInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)removeInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)addInvoicesAndPayments:(NSSet *)values;
- (void)removeInvoicesAndPayments:(NSSet *)values;
@end
