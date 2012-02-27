//
//  DestinationsPushListCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 28.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "DestinationsPushListCell.h"
//#import "DestinationsListPushList.h"

@implementation DestinationsPushListCell

@synthesize codes,acd,asr,firstName,lastName,minutesLenght,rate,wrongInput,destination,carrierName,status,delegate,notification,activity;

- (IBAction)edtitingDone:(id)sender {
    //NSLog(@"fiewt");
    UITextField *text = sender;
    NSString *editedText = text.text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setDecimalSeparator:@","];
    NSNumber *result = [formatter numberFromString:editedText];
    if (!result) {
        [formatter setDecimalSeparator:@"."];
        result = [formatter numberFromString:editedText];
        if (!result) {
            [formatter release];
            wrongInput.hidden = NO;
            return;
        }
        
    }
    [formatter release];
    
    wrongInput.hidden = YES;
    if ([sender tag] == 0) destination.rate = result;
    if ([sender tag] == 1) destination.minutesLenght = result;
    if ([sender tag] == 2) {
        NSNumber *finalResult = [NSNumber numberWithDouble:[result doubleValue] / 100];
        destination.asr = finalResult;
    }
    if ([sender tag] == 3) destination.acd = result;
    [delegate destinationsPushListDidChangesFor:destination];
    //NSLog(@"delegate:%@",delegate);
}


- (void)dealloc
{
    [status release];
    [acd release];
    [asr release];
    [firstName release];
    [lastName release];
    [minutesLenght release];
    [rate release];
    [codes release];
    [super dealloc];
}

@end
