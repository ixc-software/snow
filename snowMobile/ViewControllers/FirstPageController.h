//
//  FirstPageController.h
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstPageController : UIViewController
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIImageView *logo;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
