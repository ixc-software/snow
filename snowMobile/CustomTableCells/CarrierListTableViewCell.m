//
//  CarrierListTableView.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "CarrierListTableViewCell.h"

@implementation CarrierListTableViewCell
@synthesize activity;
@synthesize destinations;
@synthesize status;
@synthesize delete;
@synthesize carrierNameForEdit;
@synthesize name;
@synthesize responsibleFirstAndLastName;
@synthesize delegate,currentIndexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//-(void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//    NSLog(@"Editing starting");
//    if (self.editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"Animation starting");
//
//        [UIView animateWithDuration:5 delay:0 options: 0  animations:^{
//            CGRect r = self.carrierNameForEdit.frame;
//            r.size.width -= self.delete.frame.size.height;
//            
//        } completion:^(BOOL finished) {
//        }
//         ];
//
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        name.hidden = YES;
        carrierNameForEdit.hidden = NO;
        [carrierNameForEdit becomeFirstResponder];
    
    } else {
        name.hidden = NO;
        carrierNameForEdit.hidden = YES;
        [carrierNameForEdit resignFirstResponder];

    }

    // Configure the view for the selected state
}

- (IBAction)finishEditing:(id)sender {
    //NSLog(@"Update data in cell:%@ at indexpath:%@",data.text,self.currentIndexPath);
    name.hidden = NO;
    carrierNameForEdit.hidden = YES;
    [self.delegate updateData:carrierNameForEdit.text forCellAtIndexPath:self.currentIndexPath];
}


- (void)dealloc {
    [carrierNameForEdit release];
    [name release];
    [responsibleFirstAndLastName release];
    [status release];
    [delete release];
    [activity release];
    [destinations release];
    [super dealloc];
}
@end
