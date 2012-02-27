//
//  Currency.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrencyExchangeRates, CurrentCompany, InvoicesAndPayments;

@interface Currency : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *currencyExchangeRates;
@property (nonatomic, retain) CurrentCompany *currentCompany;
@property (nonatomic, retain) NSSet *invoicesAndPayments;
@end

@interface Currency (CoreDataGeneratedAccessors)

- (void)addCurrencyExchangeRatesObject:(CurrencyExchangeRates *)value;
- (void)removeCurrencyExchangeRatesObject:(CurrencyExchangeRates *)value;
- (void)addCurrencyExchangeRates:(NSSet *)values;
- (void)removeCurrencyExchangeRates:(NSSet *)values;
- (void)addInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)removeInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)addInvoicesAndPayments:(NSSet *)values;
- (void)removeInvoicesAndPayments:(NSSet *)values;
@end
