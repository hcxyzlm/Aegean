//
//  AGNImageScrollView.m
//  Aegean
//
//  Created by LingFeng-Li on 1/14/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNImageScrollView.h"

@interface AGNImageScrollView () <UIScrollViewDelegate>
@end

@implementation AGNImageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.zoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGSize originalSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(originalSize, frame.size)) {
        self.zoomScale = 1.0;
        CGSize imageSize = self.imageView.image.size;
        CGFloat wRatio = frame.size.width / imageSize.width;
        CGFloat hRatio = frame.size.height / imageSize.height;
        CGFloat ratio = MIN(wRatio, hRatio);
        self.imageView.frame = CGRectMake(0, 0, imageSize.width * ratio, imageSize.height * ratio);
        self.imageView.center = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
        self.contentSize = frame.size;
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

#pragma mark <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = CGPointMake(MAX(scrollView.bounds.size.width, scrollView.contentSize.width) * 0.5,
                                        MAX(scrollView.bounds.size.height, scrollView.contentSize.height) * 0.5);
}

#pragma mark - Action
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if ([self.imageDelegate respondsToSelector:@selector(imageScrollView:didImageTapped:)]) {
        [self.imageDelegate imageScrollView:self didImageTapped:tap];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self];
    if (!CGRectContainsPoint(self.imageView.frame, touchPoint)) {
        [self singleTap:tap];
        return;
    }
    CGFloat scale = (self.zoomScale == 1.0) ? MIN(2.55, self.maximumZoomScale) : 1.0;
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    zoomRect.origin.x    = touchPoint.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = touchPoint.y - ((zoomRect.size.height / 2.0));
    
    [self zoomToRect:zoomRect animated:YES];
}
@end
