//
//  CompanyAndUserInfoCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 02.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CompanyAndUserInfoCell;
@protocol CompanyAndUserInfoCellDelegate <NSObject>

@optional
-(void) updateData:(NSString *)data forCellAtIndexPath:(NSIndexPath *)indexPath;
-(void) approveRegistrationForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CompanyAndUserInfoCell : UITableViewCell {
    @private 
    id <CompanyAndUserInfoCellDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UILabel *state;
@property (nonatomic, retain) IBOutlet UILabel *attribute;
@property (nonatomic, retain) IBOutlet UITextField *data;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

//@property (nonatomic, retain) IBOutlet UILabel *currentData;
@property (nonatomic, retain) IBOutlet NSIndexPath *currentIndexPath;

@property (nonatomic, assign) id <CompanyAndUserInfoCellDelegate> delegate;

@property (nonatomic, retain) IBOutlet UISegmentedControl *approve;

@end
