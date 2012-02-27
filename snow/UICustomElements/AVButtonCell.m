//
//  AVButtonCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 22.07.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVButtonCell.h"


@implementation AVButtonCell
-(NSInteger) highlightsBy
{
    return [super highlightsBy];
    
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

    
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

    if ([self isHighlighted]) {
        [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
        cellFrame.origin.x -= 1;
        cellFrame.origin.y -= 1;
        cellFrame.size.height += 3;
        cellFrame.size.width += 3;
        
        NSRectFill(cellFrame);
        
    }

    [super drawWithFrame:cellFrame inView:controlView];
}

@end
