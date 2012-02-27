//
//  MainSystem.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "MainSystem.h"
#import "CountrySpecificCodeList.h"
#import "Events.h"


@implementation MainSystem

@dynamic GUID;
@dynamic countrySpecificCodeList;
@dynamic events;
- (void)awakeFromInsert {    
    [self willChangeValueForKey:@"GUID"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"GUID"];
    [self didChangeValueForKey:@"GUID"];
}
@end
