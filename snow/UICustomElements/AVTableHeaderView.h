//
//  AVTableHeaderView.h
//  snow
//
//  Created by Oleksii Vynogradov on 07.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AVTableHeaderView : NSTableHeaderCell {
@private
     NSRect currentFrame;
}

@property (assign)  NSRect currentFrame;


@end
