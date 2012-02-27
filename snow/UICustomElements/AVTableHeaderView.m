//
//  AVTableHeaderView.m
//  snow
//
//  Created by Oleksii Vynogradov on 07.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVTableHeaderView.h"


@implementation AVTableHeaderView
@synthesize currentFrame;

- (void)drawWithFrame:(NSRect)cellFrame
          highlighted:(BOOL)isHighlighted
               inView:(NSView *)view
{
    currentFrame = cellFrame;
    CGRect fillRectOne; 

    CGRect cellFrameCG = *(CGRect *)&cellFrame;
    fillRectOne =  cellFrameCG;
    [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.49 alpha:1.0] set];

    NSRectFill(*(NSRect *)&fillRectOne);

    
    fillRectOne.origin.x += 2;
    fillRectOne.origin.y += 2;
    fillRectOne.size.height -= 4;// высота
    fillRectOne.size.width -= 2;// ширина

    
    
    NSGradient *gradient = [[NSGradient alloc]
                            initWithStartingColor:[NSColor whiteColor]
                            endingColor:[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.49 alpha:1.0]];
    [gradient drawInRect:*(NSRect *)&fillRectOne angle:90.0];
    
    if (isHighlighted) {
        [[NSColor colorWithDeviceWhite:0.0 alpha:0.1] set];
        NSRectFillUsingOperation(*(NSRect *)&fillRectOne, NSCompositeSourceOver);
    }
    

    
    CGRect rectInset = CGRectInset(fillRectOne, 0.0, 0.0);

    
    
    [self drawInteriorWithFrame:*(NSRect *)&rectInset inView:view];
    [gradient release];

}

- (void)drawWithFrame:(NSRect)cellFrameMy inView:(NSView *)view
{

    [self drawWithFrame:cellFrameMy highlighted:NO inView:view];
    
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSSize size     = [self cellSizeForBounds:cellFrame];
    NSRect newRect  = cellFrame;
    
    newRect.origin.y   += (cellFrame.size.height - size.height) / 2.0;

    
    [super drawInteriorWithFrame:NSIntersectionRect(cellFrame, newRect) inView:controlView];
}


- (void)highlight:(BOOL)isHighlighted
        withFrame:(NSRect)cellFrame
           inView:(NSView *)view
{
    [self drawWithFrame:cellFrame highlighted:isHighlighted inView:view];
}

@end
