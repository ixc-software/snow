//
//  FirstPageController.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "FirstPageController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FirstPageController
@synthesize progress;
@synthesize name;
@synthesize logo;
@synthesize activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [logo.layer setShadowOffset:CGSizeMake(0, 3)];
    [logo.layer setShadowOpacity:0.8];
    [logo.layer setShadowRadius:15.0f];
    [logo.layer setShouldRasterize:YES];
    
    [logo.layer setCornerRadius:15.0f];
    [logo.layer setShadowPath:
     [[UIBezierPath bezierPathWithRoundedRect:[logo.layer bounds]
                                 cornerRadius:15.0f] CGPath]];
    logo.layer.shadowColor = [UIColor whiteColor].CGColor;
    [activity startAnimating];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setProgress:nil];
    [self setName:nil];
    [self setLogo:nil];
    [self setActivity:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [progress release];
    [name release];
    [logo release];
    [activity release];
    [super dealloc];
}
@end
