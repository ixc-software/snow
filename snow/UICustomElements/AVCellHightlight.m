//
//  NSCellHightlight.m
//  snow
//
//  Created by Oleksii Vynogradov on 07.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVCellHightlight.h"


@implementation AVCellHightlight
- (NSRect)drawingRectForBounds:(NSRect)theRect
{
	// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];
    
	// When the text field is being 
	// edited or selected, we have to turn off the magic because it screws up 
	// the configuration of the field editor.  We sneak around this by 
	// intercepting selectWithFrame and editWithFrame and sneaking a 
	// reduced, centered rect in at the last minute.
	if (mIsEditingOrSelecting == NO)
	{
		// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];
        
		// Center that in the proposed rect
		float heightDelta = newRect.size.height - textSize.height;	
		if (heightDelta > 0)
		{
			newRect.size.height -= heightDelta;
			newRect.origin.y += (heightDelta / 2);
		}
        
	} else {
        [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
        theRect.origin.x -= 1;
        theRect.origin.y -= 1;
        theRect.size.height += 2;
        theRect.size.width += 3;
        
        NSRectFill(theRect);
	}
	return newRect;
}



- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
    aRect = [self drawingRectForBounds:aRect];
    mIsEditingOrSelecting = YES;        

    [super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
    [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
    aRect.origin.x -= 1;
    aRect.origin.y -= 1;
    aRect.size.height += 2;
    aRect.size.width += 3;
    
    NSRectFill(aRect);

    mIsEditingOrSelecting = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{   
    aRect = [self drawingRectForBounds:aRect];
    mIsEditingOrSelecting = YES;
    [super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
    [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
    aRect.origin.x -= 1;
    aRect.origin.y -= 1;
    aRect.size.height += 2;
    aRect.size.width += 3;
    
    NSRectFill(aRect);

    mIsEditingOrSelecting = NO;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSSize size     = [self cellSizeForBounds:cellFrame];
    NSRect newRect  = cellFrame;
    
    newRect.origin.y   += (cellFrame.size.height - size.height) / 2.0;
    newRect.size.height = size.height;
    
    [super drawInteriorWithFrame:NSIntersectionRect(cellFrame, newRect) inView:controlView];
}
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

    if ([self isHighlighted]) {
        [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
        cellFrame.origin.x -= 1;
        cellFrame.origin.y -= 1;
        cellFrame.size.height += 2;
        cellFrame.size.width += 3;

        NSRectFill(cellFrame);

    }
    [super drawWithFrame:cellFrame inView:controlView];
}


-(NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    return nil;
}

@end
