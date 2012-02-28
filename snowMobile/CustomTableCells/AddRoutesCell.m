//
//  AddRoutesCell.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/28/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AddRoutesCell.h"

@implementation AddRoutesCell
@synthesize specific;
@synthesize codes;

/*- (void)setQuotation:(Quotation *)newQuotation {
 
 if (quotation != newQuotation) {
 [quotation release];
 quotation = [newQuotation retain];
 
 //characterLabel.text = quotation.character;
 //actAndSceneLabel.text = [NSString stringWithFormat:@"Act %d, Scene %d", quotation.act, quotation.scene];
 codes.text = quotation.quotation;
 }
 }*/


- (void)dealloc {
    [specific release];
    [codes release];
    [super dealloc];
}
@end
