//
//  CompanyAccounts.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrentCompany, InvoicesAndPayments;

@interface CompanyAccounts : NSManagedObject

@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSString * bankABA;
@property (nonatomic, retain) NSString * bankAccountNumber;
@property (nonatomic, retain) NSString * bankAddress;
@property (nonatomic, retain) NSString * bankIBAN;
@property (nonatomic, retain) NSString * bankName;
@property (nonatomic, retain) NSString * bankSwift;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * externalID;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CurrentCompany *currentCompany;
@property (nonatomic, retain) NSSet *invoicesAndPayments;
@end

@interface CompanyAccounts (CoreDataGeneratedAccessors)

- (void)addInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)removeInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)addInvoicesAndPayments:(NSSet *)values;
- (void)removeInvoicesAndPayments:(NSSet *)values;
@end
