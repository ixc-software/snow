//
//  DarkView.m
//  snow
//
//  Created by Oleksii Vynogradov on 1/17/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DarkView.h"

@implementation DarkView

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
    [[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1] set];
    NSRectFill([self bounds]);

}

@end
