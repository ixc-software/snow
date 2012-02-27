//
//  Carrier.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CarrierStuff, CompanyStuff, DestinationsListForSale, DestinationsListPushList, DestinationsListTargets, DestinationsListWeBuy, Financial;

@interface Carrier : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * emailList;
@property (nonatomic, retain) NSNumber * financialRate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * latestUpdateTime;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneList;
@property (nonatomic, retain) NSString * ratesEmail;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *carrierStuff;
@property (nonatomic, retain) CompanyStuff *companyStuff;
@property (nonatomic, retain) NSSet *destinationsListForSale;
@property (nonatomic, retain) NSSet *destinationsListPushList;
@property (nonatomic, retain) NSSet *destinationsListTargets;
@property (nonatomic, retain) NSSet *destinationsListWeBuy;
@property (nonatomic, retain) NSSet *financial;
@end

@interface Carrier (CoreDataGeneratedAccessors)

- (void)addCarrierStuffObject:(CarrierStuff *)value;
- (void)removeCarrierStuffObject:(CarrierStuff *)value;
- (void)addCarrierStuff:(NSSet *)values;
- (void)removeCarrierStuff:(NSSet *)values;
- (void)addDestinationsListForSaleObject:(DestinationsListForSale *)value;
- (void)removeDestinationsListForSaleObject:(DestinationsListForSale *)value;
- (void)addDestinationsListForSale:(NSSet *)values;
- (void)removeDestinationsListForSale:(NSSet *)values;
- (void)addDestinationsListPushListObject:(DestinationsListPushList *)value;
- (void)removeDestinationsListPushListObject:(DestinationsListPushList *)value;
- (void)addDestinationsListPushList:(NSSet *)values;
- (void)removeDestinationsListPushList:(NSSet *)values;
- (void)addDestinationsListTargetsObject:(DestinationsListTargets *)value;
- (void)removeDestinationsListTargetsObject:(DestinationsListTargets *)value;
- (void)addDestinationsListTargets:(NSSet *)values;
- (void)removeDestinationsListTargets:(NSSet *)values;
- (void)addDestinationsListWeBuyObject:(DestinationsListWeBuy *)value;
- (void)removeDestinationsListWeBuyObject:(DestinationsListWeBuy *)value;
- (void)addDestinationsListWeBuy:(NSSet *)values;
- (void)removeDestinationsListWeBuy:(NSSet *)values;
- (void)addFinancialObject:(Financial *)value;
- (void)removeFinancialObject:(Financial *)value;
- (void)addFinancial:(NSSet *)values;
- (void)removeFinancial:(NSSet *)values;
@end
