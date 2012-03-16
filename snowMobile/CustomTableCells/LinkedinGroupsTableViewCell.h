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
@property (retain, nonatomic) IBOutlet UITextField *postingTitle;
@property (retain, nonatomic) IBOutlet UISwitch *includeRates;
@property (retain, nonatomic) IBOutlet UILabel *priceCorrectionTitle;
@property (retain, nonatomic) IBOutlet UILabel *priceCorrectionPercent;
@property (retain, nonatomic) IBOutlet UIStepper *priceCorrectionStepper;
@property (retain, nonatomic) IBOutlet UILabel *includeCountries;
@property (retain, nonatomic) IBOutlet UILabel *headTitle;

@end
