//
//  AGNPhotosPickerController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosPickerController.h"
#import "AGNAlbumsViewController.h"
#import "Marcos.h"

@interface AGNPhotosPickerController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIViewController *lastViewController;
@end

@implementation AGNPhotosPickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        AGNAlbumsViewController *albumsVC = [[AGNAlbumsViewController alloc] init];
        self.viewControllers = @[albumsVC];
        
        self.navigationBar.barTintColor = HEXCOLOR(0x343339);
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.toolbar.barTintColor = [UIColor whiteColor];
        self.tintColor = HEXCOLOR(0x08bb08);
        self.maximumNumberOfSelectedPhotos = NSUIntegerMax;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = self;
    
    self.navigationBar.barStyle = [self isDarkColor:self.navigationBar.barTintColor] ? UIBarStyleBlack : UIBarStyleDefault;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationBar.tintColor};
    self.navigationBar.translucent = YES;
    self.toolbar.translucent = YES;
}

- (BOOL)isDarkColor:(UIColor *)color {
    BOOL isDarkColor;
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([color CGColor]);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    switch (colorSpaceModel) {
        case kCGColorSpaceModelUnknown: {
            break;
        }
        case kCGColorSpaceModelMonochrome: {
            CGFloat white = 0;
            [color getWhite:&white alpha:nil];
            isDarkColor = (white < 0.5);
            break;
        }
        case kCGColorSpaceModelRGB: {
            const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
            CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
            isDarkColor = (colorBrightness < 0.5);
            break;
        }
        case kCGColorSpaceModelCMYK: {
            break;
        }
        case kCGColorSpaceModelLab: {
            break;
        }
        case kCGColorSpaceModelDeviceN: {
            break;
        }
        case kCGColorSpaceModelIndexed: {
            break;
        }
        case kCGColorSpaceModelPattern: {
            break;
        }
        default:
            break;
    }
    return isDarkColor;
}

#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    SEL selector = @selector(navigationController:animationControllerForOperation:fromViewController:toViewController:);
    id<UIViewControllerAnimatedTransitioning> result = nil;
    if ([fromVC conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [fromVC respondsToSelector:selector]) {
        result = [(id<UINavigationControllerDelegate>)fromVC navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
        if (result) {
            self.lastViewController = fromVC;
        }
    }
    return result;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([self.lastViewController conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [self.lastViewController respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [(id<UINavigationControllerDelegate>)self.lastViewController navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

#pragma mark <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Action
- (void)cancel:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.pickerDelegate respondsToSelector:@selector(photosPickerControllerDidCancel:)]) {
        [picker.pickerDelegate photosPickerControllerDidCancel:picker];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
