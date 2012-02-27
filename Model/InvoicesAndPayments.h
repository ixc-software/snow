//
//  InvoicesAndPayments.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompanyAccounts, CompanyStuff, Currency, Financial;

@interface InvoicesAndPayments : NSManagedObject

@property (nonatomic, retain) NSNumber * amountCarrierSide;
@property (nonatomic, retain) NSNumber * amountConfirmed;
@property (nonatomic, retain) NSNumber * amountOurSide;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * externalID;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * isInvoice;
@property (nonatomic, retain) NSNumber * isReceived;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * pathToFile;
@property (nonatomic, retain) NSDate * paymentDate;
@property (nonatomic, retain) NSDate * usagePeriodFinish;
@property (nonatomic, retain) NSDate * usagePeriodStart;
@property (nonatomic, retain) CompanyAccounts *companyAccounts;
@property (nonatomic, retain) CompanyStuff *companyStuff;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, retain) Financial *financial;

@end
