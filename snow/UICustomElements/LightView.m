//
//  LightView.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.01.12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "LightView.h"

@implementation LightView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.

    [[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1] set];
    NSRectFill([self bounds]);

}

@end
