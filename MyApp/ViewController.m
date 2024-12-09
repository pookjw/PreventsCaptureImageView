//
//  ViewController.m
//  MyApp
//
//  Created by Jinwoo Kim on 12/9/24.
//

#import "ViewController.h"
#import "PreventsCaptureImageView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet PreventsCaptureImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[UIImage imageNamed:@"1"] prepareForDisplayWithCompletionHandler:^(UIImage * _Nullable image) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            ((PreventsCaptureImageView *)self.view).image = image;
//        });
//    }];
    self.imageView.image = [UIImage imageNamed:@"1"];
}


@end
