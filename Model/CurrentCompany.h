//
//  CurrentCompany.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompanyAccounts, CompanyStuff, Currency, DatabaseConnections, OperationNecessaryToApprove;

@interface CurrentCompany : NSManagedObject

@property (nonatomic, retain) NSString * additionalInformation;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * carriersCount;
@property (nonatomic, retain) NSString * companyAdminGUID;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * destinationsForSaleCount;
@property (nonatomic, retain) NSNumber * destinationsPushListCount;
@property (nonatomic, retain) NSNumber * destinationsTargetsCount;
@property (nonatomic, retain) NSNumber * destinationsWeBuyCount;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * isRegistrationDone;
@property (nonatomic, retain) NSNumber * isRegistrationProcessed;
@property (nonatomic, retain) NSNumber * isVisibleForCommunity;
@property (nonatomic, retain) NSString * localPhoneList;
@property (nonatomic, retain) NSString * logoURL;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ratesEmail;
@property (nonatomic, retain) NSNumber * stuffCount;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *companyAccounts;
@property (nonatomic, retain) NSSet *companyStuff;
@property (nonatomic, retain) NSSet *currency;
@property (nonatomic, retain) NSSet *databaseConnections;
@property (nonatomic, retain) NSSet *operationNecessaryToApprove;
@end

@interface CurrentCompany (CoreDataGeneratedAccessors)

- (void)addCompanyAccountsObject:(CompanyAccounts *)value;
- (void)removeCompanyAccountsObject:(CompanyAccounts *)value;
- (void)addCompanyAccounts:(NSSet *)values;
- (void)removeCompanyAccounts:(NSSet *)values;
- (void)addCompanyStuffObject:(CompanyStuff *)value;
- (void)removeCompanyStuffObject:(CompanyStuff *)value;
- (void)addCompanyStuff:(NSSet *)values;
- (void)removeCompanyStuff:(NSSet *)values;
- (void)addCurrencyObject:(Currency *)value;
- (void)removeCurrencyObject:(Currency *)value;
- (void)addCurrency:(NSSet *)values;
- (void)removeCurrency:(NSSet *)values;
- (void)addDatabaseConnectionsObject:(DatabaseConnections *)value;
- (void)removeDatabaseConnectionsObject:(DatabaseConnections *)value;
- (void)addDatabaseConnections:(NSSet *)values;
- (void)removeDatabaseConnections:(NSSet *)values;
- (void)addOperationNecessaryToApproveObject:(OperationNecessaryToApprove *)value;
- (void)removeOperationNecessaryToApproveObject:(OperationNecessaryToApprove *)value;
- (void)addOperationNecessaryToApprove:(NSSet *)values;
- (void)removeOperationNecessaryToApprove:(NSSet *)values;
@end
