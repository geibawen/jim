//
//  RRSMapView.m
//  rrmapanalyzer
//
//  Created by jianbin on 2020/12/10.
//  Copyright © 2020 jim. All rights reserved.
//

#define MIN_SCAL 1
#define MAX_SCAL 10

#import "RRSMapView.h"
#import "RRSMapParser.h"

@interface RRSMapView() <UIGestureRecognizerDelegate>


@end

@implementation RRSMapView

CGSize _selfSize;

CGPoint _from;
NSInteger _lastTouchs = 0;
CGFloat _rotation = 0;
CGFloat _scale = 1;
CGPoint _translation;


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _from = CGPointZero;
    _translation = CGPointZero;
    
    [self addSubview:self.mapImageView];

    // 点击
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    // 三指点击
    UITapGestureRecognizer *tripleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    tripleGesture.numberOfTapsRequired = 1;
    tripleGesture.numberOfTouchesRequired = 3;
    tripleGesture.delegate = self;
    [self addGestureRecognizer:tripleGesture];
    
    // 缩放
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
    
    // 移动
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    // 旋转
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
    
    _selfSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    
    return self;
}

- (UIImageView *)mapImageView {
    if (!_mapImageView) {
        _mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _mapImageView;
}

- (void)layoutSubviews {
    if (self.bounds.size.height != _selfSize.height && self.bounds.size.width != _selfSize.width) {
        _selfSize.height = self.bounds.size.height;
        _selfSize.width = self.bounds.size.width;
        [self scaleToFit:NO];
    }
}

#pragma mark - Internal Function

- (void)scaleToFit:(BOOL)animated {
    UIImageView *view = self.mapImageView;
    if (view) {
        CGFloat scaleX = self.bounds.size.width / view.bounds.size.width;
        CGFloat scaleY = self.bounds.size.height / view.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY);
        _scale = scale;
        _rotation = 0;
        if (animated) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self resetTransform];
            } completion:nil];
        }else {
            [self resetTransform];
        }
    }
}

- (void)resetTransform {
    UIImageView *view = self.mapImageView;
    if (view) {
        view.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        view.transform = CGAffineTransformMakeScale(_scale, _scale);
    }
}

- (void)scaleAt:(CGPoint)center scale:(CGFloat)scale {
    CGFloat formerScale = _scale;
    _scale = scale * _scale;
    _scale = MIN(MAX(MIN_SCAL, _scale), MAX_SCAL);
    CGFloat currentScale = _scale/formerScale;
    
    CGFloat x = self.mapImageView.center.x;
    CGFloat y = self.mapImageView.center.y;
    CGFloat x1 = currentScale * (x - center.x) + center.x;
    CGFloat y1 = currentScale * (y - center.y) + center.y;
    self.mapImageView.center = CGPointMake(x1, y1);
    self.mapImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotation);
    self.mapImageView.transform = CGAffineTransformScale(self.mapImageView.transform, _scale, _scale);
}

- (void)rotateAt:(CGPoint)center rotation:(CGFloat)rotation {
    _rotation = _rotation + rotation;
    CGFloat x1 = self.mapImageView.center.x;
    CGFloat y1 = self.mapImageView.center.y;
    CGFloat x0 = center.x;
    CGFloat y0 = self.bounds.size.height - center.y;
    CGFloat x = (x1 - x0) * cos(rotation) - (y1 - y0) * sin(rotation) + x0;
    CGFloat y = (y1 - y0) * cos(rotation) + (x1 - x0) * sin(rotation) + y0;
    
    self.mapImageView.center = CGPointMake(x, y);
    self.mapImageView.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity, _rotation), _scale, _scale);
}

- (void)translate:(CGFloat)x y:(CGFloat)y {
    _translation = CGPointMake(_translation.x + x, _translation.y + y);
    self.mapImageView.center = CGPointMake(self.mapImageView.center.x + x, self.mapImageView.center.y + y);
}

- (void)gestureRecognizer:(UIGestureRecognizer *)gesture {
    if (self.mapImageView) {
        if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)gesture;
            if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
                // 计算缩放的中心点和缩放比例，每次缩放的比例需要累计
                CGPoint center = [pinchGesture locationInView:self];
                if (pinchGesture.numberOfTouches == 2) {
                    CGPoint center0 = [pinchGesture locationOfTouch:0 inView:self];
                    CGPoint center1 = [pinchGesture locationOfTouch:1 inView:self];
                    center = CGPointMake((center0.x + center1.x)/2, (center0.y + center1.y)/2);
                }
                [self scaleAt:center scale:pinchGesture.scale];
                pinchGesture.scale = 1;
            }
        } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPinchGestureRecognizer *panGesture = (UIPinchGestureRecognizer *)gesture;
            CGPoint location = [panGesture locationInView:self];
            if (panGesture.state == UIGestureRecognizerStateBegan) {
                // 记录开始位置
                _from = location;
                _lastTouchs = gesture.numberOfTouches;
            } else if (panGesture.state == UIGestureRecognizerStateChanged) {
                if (_lastTouchs != panGesture.numberOfTouches) {
                    _from = location;
                }
                // 计算偏移量
                _lastTouchs = panGesture.numberOfTouches;
                CGFloat x = location.x - _from.x;
                CGFloat y = location.y - _from.y;
                _from = location;
                [self translate:x y:y];
            }
        } else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            UIRotationGestureRecognizer *rotatioGesture = (UIRotationGestureRecognizer *)gesture;
            if (rotatioGesture.state == UIGestureRecognizerStateBegan || rotatioGesture.state == UIGestureRecognizerStateChanged) {
                // 计算旋转的中心点和旋转角度，每次旋转的角度需要累计
                CGPoint center = [rotatioGesture locationInView:self];
                if (rotatioGesture.numberOfTouches == 2) {
                    CGPoint center0 = [rotatioGesture locationOfTouch:0 inView:self];
                    CGPoint center1 = [rotatioGesture locationOfTouch:1 inView:self];
                    center = CGPointMake((center0.x + center1.x)/2, (center0.y + center1.y)/2);
                }
                [self rotateAt:center rotation:rotatioGesture.rotation];
                rotatioGesture.rotation = 0;
            }
        } else if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)gesture;
            if (tapGesture.numberOfTouches == 1) {
                //处理单击
                [self scaleToFit:YES];
            } else if (tapGesture.numberOfTouches == 3) {
                //处理单击
            }
        }
    }
}

#pragma mark - API

- (void)setMapFileUrl:(NSURL *)url {
    [[RRSMapParser sharedInstance] parse:url result:^(NSDictionary *resultDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL* mapUrl = [NSURL URLWithString:[[resultDict objectForKey:@"map"] objectForKey:@"image"]];
            NSData * mapImageData = [NSData dataWithContentsOfURL:mapUrl];
            UIImage * mapImage = [UIImage imageWithData:mapImageData];
            
            NSNumber* width = [[resultDict objectForKey:@"map"] objectForKey:@"width"];
            NSNumber* height = [[resultDict objectForKey:@"map"] objectForKey:@"height"];
            
            self.mapImageView.image = mapImage;
            self.mapImageView.width = [width floatValue];
            self.mapImageView.height = [height floatValue];
        });
    }];
}

- (void)setPathFileUrl:(NSURL *)url {
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        || [gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]
        || [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])
        && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (otherGestureRecognizer.numberOfTouches == 3) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
