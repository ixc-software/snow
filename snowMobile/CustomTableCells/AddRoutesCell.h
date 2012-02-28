//
//  AddRoutesCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/28/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddRoutesCodesCellTextView.h"

@interface AddRoutesCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *specific;
@property (retain, nonatomic) IBOutlet AddRoutesCodesCellTextView *codes;

@end
