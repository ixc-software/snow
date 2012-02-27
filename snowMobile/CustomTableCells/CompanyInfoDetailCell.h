//
//  CompanyInfoDetailCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CompanyAddController.h"

@class CompanyInfoDetailCell;

@protocol CompanyInfoDetailCellDelegate;

@interface CompanyInfoDetailCell : UITableViewCell {
@private 
    id <CompanyInfoDetailCellDelegate> delegate;

}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *admin;
@property (nonatomic, retain) IBOutlet UILabel *url;
@property (nonatomic, retain) IBOutlet UILabel *members;
@property (nonatomic, retain) IBOutlet UILabel *destinations;
@property (nonatomic, retain) IBOutlet UILabel *adminFirstName;
@property (nonatomic, retain) IBOutlet UILabel *adminLastName;

//@property (nonatomic, retain) IBOutlet UILabel *status;
@property (nonatomic, retain) IBOutlet UILabel *isVisibleLabel;

@property (nonatomic, retain) IBOutlet UISegmentedControl *notification;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) IBOutlet UITextField *changeCompanyName;
@property (nonatomic, retain) IBOutlet UITextField *changeCompanyURL;
@property (nonatomic, retain) IBOutlet UIView *companyProcess;

@property (nonatomic, assign) id <CompanyInfoDetailCellDelegate> delegate;


@end

@protocol CompanyInfoDetailCellDelegate <NSObject>

@optional
-(void)companyDidChangesFor:(NSString *)placeholder;


@end
