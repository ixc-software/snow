//
//  CountrySpecificCodeList.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CodesList, MainSystem;

@interface CountrySpecificCodeList : NSManagedObject

@property (nonatomic, retain) NSString * codes;
@property (nonatomic, retain) NSString * codesNormalized;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * countryNormalized;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * opened;
@property (nonatomic, retain) NSNumber * rowHeight;
@property (nonatomic, retain) NSString * specific;
@property (nonatomic, retain) NSString * specificNormalized;
@property (nonatomic, retain) NSSet *codesList;
@property (nonatomic, retain) MainSystem *mainSystem;
@end

@interface CountrySpecificCodeList (CoreDataGeneratedAccessors)

- (void)addCodesListObject:(CodesList *)value;
- (void)removeCodesListObject:(CodesList *)value;
- (void)addCodesList:(NSSet *)values;
- (void)removeCodesList:(NSSet *)values;
@end
