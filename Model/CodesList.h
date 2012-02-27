//
//  CodesList.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CountrySpecificCodeList;

@interface CodesList : NSManagedObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) CountrySpecificCodeList *countrySpecificCodesList;

@end
