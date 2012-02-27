//
//  CurrencyExchangeRates.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Currency;

@interface CurrencyExchangeRates : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) Currency *currency;

@end
