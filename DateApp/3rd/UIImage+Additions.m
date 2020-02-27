//
//  UIImage+Additions.m
//  love-ios
//
//  Created by Lim Daehyun on 2014. 7. 30..
//  Copyright (c) 2014년 DaumKakao. All rights reserved.
//

#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Additions)

+ (UIImage *)colorImage:(UIColor *)color
{
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)halfSizeImageWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGSize imageSize = image.size;
    CGSize newSize = CGSizeMake(imageSize.width/2, imageSize.height/2);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageContentsOfFileNamed:(NSString *)name {
    
    UIImage *image = nil;
    
    if(name != nil)
    {
        NSString *imageContentsPath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        if(imageContentsPath != nil)
        {
            image = [UIImage imageWithContentsOfFile:imageContentsPath];
        }
    }
    
    return image;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0.0, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
@end
