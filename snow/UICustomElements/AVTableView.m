//
//  AVTableView.m
//  snow
//
//  Created by Oleksii Vynogradov on 22.07.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AVTableView.h"


@implementation AVTableView

//- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row
//{
//    NSCell* cell = [super preparedCellAtColumn:column row:row];
//    
//    [cell setHighlighted:(row == [self selectedRow])];
//    
//    return cell;
//}

- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
    
    // this method is asking us to draw the hightlights for 
    // all of the selected rows that are visible inside theClipRect
    
    // 1. get the range of row indexes that are currently visible
    // 2. get a list of selected rows
    // 3. iterate over the visible rows and if their index is selected
    // 4. draw our custom highlight in the rect of that row.
    
    NSRange         aVisibleRowIndexes = [self rowsInRect:theClipRect];
    NSIndexSet *    aSelectedRowIndexes = [self selectedRowIndexes];
    CGFloat             aRow = aVisibleRowIndexes.location;
    CGFloat             anEndRow = aRow + aVisibleRowIndexes.length;
    NSGradient *    gradient;
    NSColor *       pathColor;
    
    // if the view is focused, use highlight color, otherwise use the out-of-focus highlight color
    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow])
    {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:
                     [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1], 0.0, 
                     [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1], 1.0, nil]; //160 80
        
        pathColor = [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1];
    }
    else
    {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:
                     [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1], 0.0, 
                     [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1], 1.0, nil];
        
        pathColor = [NSColor colorWithDeviceRed:0.29 green:0.25 blue:0.42 alpha:1];
    }
    
    // draw highlight for the visible, selected rows
    for (CGFloat aRow = aVisibleRowIndexes.location; aRow < anEndRow; aRow++)
    {
        if([aSelectedRowIndexes containsIndex:aRow])
        {
            NSRect aRowRect = NSInsetRect([self rectOfRow:aRow], 0, 1); //first is horizontal, second is vertical
            NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:aRowRect xRadius:0.0 yRadius:0.0]; //6.0
            [path setLineWidth: 0];
            [pathColor set];
            [path stroke];
            
            [gradient drawInBezierPath:path angle:90];
        }
    }
    [gradient release];
}

@end
