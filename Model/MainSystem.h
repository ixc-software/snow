//
//  MainSystem.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CountrySpecificCodeList, Events;

@interface MainSystem : NSManagedObject

@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSSet *countrySpecificCodeList;
@property (nonatomic, retain) NSSet *events;
@end

@interface MainSystem (CoreDataGeneratedAccessors)

- (void)addCountrySpecificCodeListObject:(CountrySpecificCodeList *)value;
- (void)removeCountrySpecificCodeListObject:(CountrySpecificCodeList *)value;
- (void)addCountrySpecificCodeList:(NSSet *)values;
- (void)removeCountrySpecificCodeList:(NSSet *)values;
- (void)addEventsObject:(Events *)value;
- (void)removeEventsObject:(Events *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
