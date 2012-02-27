//
//  DestinationsPushListCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 28.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DestinationsListPushList.h"

@class AddRoutesCodesCellTextView;
@protocol DestinationsPushListTableViewDelegate;

@interface DestinationsPushListCell : UITableViewCell {
@private 
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *notification;

@property (nonatomic, retain) IBOutlet UILabel *firstName;
@property (nonatomic, retain) IBOutlet UILabel *lastName;
@property (nonatomic, retain) IBOutlet UILabel *carrierName;

@property (nonatomic, retain) IBOutlet UILabel *wrongInput;

@property (nonatomic, retain) IBOutlet UILabel *status;

@property (nonatomic, retain) IBOutlet UITextField *acd;
@property (nonatomic, retain) IBOutlet UITextField *asr;
@property (nonatomic, retain) IBOutlet UITextField *minutesLenght;
@property (nonatomic, retain) IBOutlet UITextField *rate;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) IBOutlet AddRoutesCodesCellTextView *codes;

@property (nonatomic, assign) DestinationsListPushList *destination;
@property (nonatomic, assign) id <DestinationsPushListTableViewDelegate> delegate;



@end

@protocol DestinationsPushListTableViewDelegate <NSObject>

@optional
-(void)destinationsPushListDidChangesFor:(DestinationsListPushList *)object;

@end
