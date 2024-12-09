//
//  PreventsCaptureImageView.h
//  MyApp
//
//  Created by Jinwoo Kim on 12/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreventsCaptureImageView : UIView
@property (nonatomic, nullable) UIImage *image;
@property (nonatomic) BOOL preventsCapture;
@end

NS_ASSUME_NONNULL_END
