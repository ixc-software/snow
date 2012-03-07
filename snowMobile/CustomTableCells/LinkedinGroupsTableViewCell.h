//
//  LinkedinGroupsTableViewCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkedinGroupsTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UISwitch *groupSwitch;
@property (retain, nonatomic) IBOutlet UILabel *groupName;
@property (retain, nonatomic) IBOutlet UITextView *bodyForEdit;
@property (retain, nonatomic) IBOutlet UITextView *signature;
@property (retain, nonatomic) IBOutlet UILabel *routesList;

@end
