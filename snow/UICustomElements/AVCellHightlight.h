//
//  NSCellHightlight.h
//  snow
//
//  Created by Oleksii Vynogradov on 07.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AVCellHightlight : NSTextFieldCell {
@private
    BOOL mIsEditingOrSelecting;
}

@end
