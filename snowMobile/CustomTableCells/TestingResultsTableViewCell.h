//
//  TestingResultsTableViewCell.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TestsResultsController;

@interface TestingResultsTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *numberA;
@property (retain, nonatomic) IBOutlet UILabel *number;
@property (retain, nonatomic) IBOutlet UILabel *inputPackets;
@property (retain, nonatomic) IBOutlet UILabel *outputPackets;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *responseTime;
@property (retain, nonatomic) IBOutlet UISegmentedControl *pddTime;
@property (retain, nonatomic) IBOutlet UISegmentedControl *callTime;
@property (retain, nonatomic) IBOutlet UILabel *fasReason;
@property (retain, nonatomic) IBOutlet UIButton *markFasButton;

@property (assign, nonatomic) TestsResultsController *delegate ;
@property (assign, nonatomic) BOOL isPlayingCall;
@property (assign, nonatomic) BOOL isPlayingRing;
@property (assign, nonatomic) BOOL isFas;

@property (retain, nonatomic) NSIndexPath *indexPath ;

@end
