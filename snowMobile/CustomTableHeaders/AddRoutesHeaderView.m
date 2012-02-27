//
//  SectionHeaderView.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AddRoutesHeaderView.h"
#import "mobileAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation AddRoutesHeaderView

@synthesize titleLabel, disclosureButton, delegate, section,objectID,sectionName,opened;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}
-(id)initWithFrame:(CGRect)frame
          objectID:(NSManagedObjectID *)_objectID 
           section:(NSInteger)sectionNumber
       sectionName:(NSString *)_sectionName
            opened:(BOOL)_opened
          delegate:(id <SectionHeaderViewDelegate>)aDelegate ;
{
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        // Set up the tap gesture recognizer.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        delegate = aDelegate;        
        objectID = _objectID;
        sectionName = _sectionName;
        opened = _opened;
        
        self.userInteractionEnabled = YES;
        
        // Create and configure the title label.
        section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 45.0;
        titleLabelFrame.origin.y -= 2.0;
        
        titleLabelFrame.size.width -= 45.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.text = sectionName;
        titleLabel.font = [UIFont systemFontOfSize:18.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(1, 1);

        [self addSubview:titleLabel];
        
        //disclosureButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        self.disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];

        disclosureButton.frame = CGRectMake(0.0, 8.0, 45.0, 45.0);
        //[disclosureButton setHighlighted:YES];
        [disclosureButton setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [disclosureButton setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        [disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        disclosureButton.selected = _opened;
        [self addSubview:disclosureButton];
        
        // Set the colors for the gradient layer.
        static NSMutableArray *colors = nil;
        if (colors == nil) {
            colors = [[NSMutableArray alloc] initWithCapacity:2];
            UIColor *color = nil;
            color = [UIColor colorWithRed:0.82 green:0.84 blue:0.87 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:0.15 green:0.15 blue:0.49 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            //color = [UIColor colorWithRed:0.15 green:0.15 blue:0.49 alpha:1.0];
            //[colors addObject:(id)[color CGColor]];
        }
        [(CAGradientLayer *)self.layer setColors:colors];
        //[(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.91], [NSNumber numberWithFloat:1.0], nil]];
        [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0], nil]];
         
    }
    
    return self;
}

-(IBAction)toggleOpen:(id)sender {
    //UITapGestureRecognizer *currentButton = sender;
    
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction;
                      //changedTo:(BOOL)state;
{
    
    //NSLog(@"todge for country/specific:%@/%@ previous state:%@",object.country,object.specific,[object.opened boolValue] ? @"YES" : @"NO");
    
    // worked previous block
    mobileAppDelegate *appDelegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    NSManagedObject *object = [moc objectWithID:objectID];
    
    BOOL currentState = opened;
    
    [object setValue:[NSNumber numberWithBool:!currentState] forKey:@"opened"];
    opened = !currentState;

    self.disclosureButton.selected = !currentState;

    //NSLog(@"todge for country/specific:%@/%@ new state:%@",object.country,object.specific,self.disclosureButton.selected ? @"YES" : @"NO");

    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (disclosureButton.selected) {
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [delegate sectionHeaderView:self sectionOpened:section];
                //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [delegate sectionHeaderView:self sectionClosed:section];
            }
        }
    } 
    
}


- (void)dealloc {
    //[event release];
    [titleLabel release];
    [disclosureButton release];
    [super dealloc];
}


@end
