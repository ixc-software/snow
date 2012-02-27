//
//  BoolToString.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.07.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "BoolToString.h"


@implementation BoolToString

- (id)transformedValue:(id)value {
    if ([value boolValue])
    {
        return @"Yes";
    }
    return @"No";
}

@end
