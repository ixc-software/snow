//
//  CarrierListTableView.h
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarrierListTableViewCell;
@protocol CarrierListTableViewDelegate <NSObject>

@optional
-(void) updateData:(NSString *)data forCellAtIndexPath:(NSIndexPath *)indexPath;
-(void) approveRegistrationForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
@interface CarrierListTableViewCell : UITableViewCell {
@private 
    id <CarrierListTableViewDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UITextField *carrierNameForEdit;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *responsibleFirstAndLastName;
@property (nonatomic, assign) id <CarrierListTableViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet NSIndexPath *currentIndexPath;
@property (retain, nonatomic) IBOutlet UILabel *status;
@property (retain, nonatomic) IBOutlet UIButton *delete;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (retain, nonatomic) IBOutlet UILabel *destinations;



@end
