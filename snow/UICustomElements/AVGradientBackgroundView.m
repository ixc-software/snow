//
//  AVGradientBackgroundView.m
//  snow
//
//  Created by Oleksii Vynogradov on 08.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVGradientBackgroundView.h"


@implementation AVGradientBackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawWithFrame:(NSRect)cellFrame
          highlighted:(BOOL)isHighlighted
               inView:(NSView *)view
{
    CGRect cellFrameCG = *(CGRect *)&cellFrame;
    [[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.49 alpha:1.0] set];
    
    NSRectFill(*(NSRect *)&cellFrameCG);
    

    cellFrameCG.origin.y += 2;
    cellFrameCG.size.height -= 4;// высота
    cellFrameCG.size.width -= 2;// ширина*/


    
    NSGradient *gradient = [[NSGradient alloc]
                            initWithStartingColor:[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.49 alpha:1.0]
                            endingColor:[NSColor whiteColor]];
    
    [gradient drawInRect:*(NSRect *)&cellFrameCG angle:90.0];
    [gradient release];
    

}

- (void)drawWithFrame:(NSRect)cellFrameMy inView:(NSView *)view
{

    
    [self drawWithFrame:cellFrameMy highlighted:NO inView:view];
    
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self drawWithFrame:dirtyRect highlighted:NO inView:nil];

}

@end
