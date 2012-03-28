//
//  TestingResultsTableViewCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestingResultsTableViewCell.h"
#import "TestsResultsController.h"

@implementation TestingResultsTableViewCell
@synthesize numberA;
@synthesize number;
@synthesize inputPackets;
@synthesize outputPackets;
@synthesize playButton;
@synthesize responseTime;
@synthesize pddTime;
@synthesize callTime;
@synthesize fasReason;
@synthesize markFasButton;
@synthesize delegate,indexPath,isPlayingCall,isPlayingRing,isFas;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)unmarkAsFas:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(unmarkAsFasForIndexPath:)]) {
        
        [delegate unmarkAsFasForIndexPath:self.indexPath];
        [self.markFasButton setImage:[UIImage imageNamed:@"markAsFas.png"] forState:UIControlStateNormal];
        [self.markFasButton addTarget:self action:@selector(markAsFas:) forControlEvents:UIControlEventTouchUpInside];
        [self.markFasButton removeTarget:self action:@selector(unmarkAsFas:) forControlEvents:UIControlEventTouchUpInside];
        self.number.textColor = [UIColor greenColor];
        self.fasReason.hidden = YES;

    }

}

-(IBAction)markAsFas:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(markAsFasForIndexPath:)]) {
        if (isFas) {
            [delegate unmarkAsFasForIndexPath:self.indexPath];
            [self.markFasButton setImage:[UIImage imageNamed:@"markAsFas.png"] forState:UIControlStateNormal];
            self.isFas = NO;
            self.number.textColor = [UIColor greenColor];
            self.fasReason.hidden = YES;
        } else {
            self.isFas = YES;
            
            [delegate markAsFasForIndexPath:self.indexPath];
            [self.markFasButton setImage:[UIImage imageNamed:@"unmarkAsFas.png"] forState:UIControlStateNormal];
            self.number.textColor = [UIColor redColor];
            self.fasReason.hidden = NO;
        }

    }

}

-(IBAction)playRing:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(playRingForIndexPath:)]) {
        if (isPlayingRing) {
            [delegate playRingForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"playNew.png"] forState:UIControlStateNormal];
            self.isPlayingRing = NO;
            
        } else {
            self.isPlayingRing = YES;
            
            [delegate stopPlayRingForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"stopNew.png"] forState:UIControlStateNormal];
            
        }

    }

}


-(IBAction)playCall:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(playCallForIndexPath:)]) {
        if (isPlayingCall) {
            [delegate stopPlayCallForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"playNew.png"] forState:UIControlStateNormal];
            self.isPlayingCall = NO;

        } else {
            self.isPlayingCall = YES;

            [delegate playCallForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"stopNew.png"] forState:UIControlStateNormal];

        }
    }
    
}




- (void)dealloc {
    [indexPath release];
    [number release];
    [inputPackets release];
    [outputPackets release];
    [playButton release];
    [responseTime release];
    [pddTime release];
    [callTime release];
    [fasReason release];
    [markFasButton release];
    [numberA release];
    [super dealloc];
}
@end
