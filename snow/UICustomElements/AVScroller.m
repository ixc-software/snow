//
//  NSViewFix.m
//  snow
//
//  Created by Oleksii Vynogradov on 07.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVScroller.h"


@implementation AVScroller

- (id)initWithFrame:(NSRect)frame
{
    //NSRect newFrame = NSRect
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"Frame:%@",frame);
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+(CGFloat) scrollerWidth{
    return 5;
}

+(CGFloat) scrollerWidthForControlSize:(NSControlSize)controlSize{
    return 5;
}

- (void) drawBackground:(NSRect) rect{

    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:0 yRadius:0];
    [[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1] set];
    [path fill];
}

- (void) drawRect: (NSRect)dirtyRect
{
    //CGRect newRect = CGRectMake(dirtyRect.origin.x, dirtyRect.origin.y - 40, dirtyRect.size.width, dirtyRect.size.height - 40);
    //[self setFrame:*(NSRect *)&newRect];
    NSDrawWindowBackground([self bounds]);
    [self drawKnob];
}

- (void)drawKnob{
    [self drawBackground:[self rectForPart:0]];
    [self drawBackground:[self rectForPart:1]];
    [self drawBackground:[self rectForPart:2]];
    [self drawBackground:[self rectForPart:3]];
    [self drawBackground:[self rectForPart:4]];
    [self drawBackground:[self rectForPart:5]];
    [self drawBackground:[self rectForPart:6]];
    
    
    NSRect knobRect = [self rectForPart:NSScrollerKnob];
    NSRect newRect = NSMakeRect((knobRect.size.width - [AVScroller scrollerWidth]) / 2, knobRect.origin.y, [AVScroller scrollerWidth], knobRect.size.height);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:5 yRadius:5];
    [[NSColor blackColor] set];
    [path fill];
    [self setArrowsPosition:NSScrollerArrowsNone];

}


- (NSControlTint)controlTint
{
    return NSClearControlTint;
}

- (NSScrollArrowPosition)arrowsPosition
{
    return NSScrollerArrowsNone;
}
@end
