//
//  UIImage+Additions.h
//  love-ios
//
//  Created by Lim Daehyun on 2014. 7. 30..
//  Copyright (c) 2014년 DaumKakao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+ (UIImage *)colorImage:(UIColor *)color;
+ (UIImage *)imageContentsOfFileNamed:(NSString *)name;
+ (UIImage*)halfSizeImageWithName:(NSString *)imageName;
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color;
@end