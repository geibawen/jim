//
//  RRSMapView.m
//  rrmapanalyzer
//
//  Created by jianbin on 2020/12/10.
//  Copyright © 2020 jim. All rights reserved.
//

#define MIN_SCAL 1
#define MAX_SCAL 5

#import "RRSMapView.h"

@interface RRSMapView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView                     *mapImageView;

@end

@implementation RRSMapView

CGPoint _from;
int _lastTouchs = 0;
CGFloat _rotation = 0;
CGFloat _scale = 0;
CGPoint _translation;


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _from = CGPointZero;
    _translation = CGPointZero;
    
    [self addSubview:self.mapImageView];

    // 双指点击
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 2;
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
    
    return self;
}

- (UIImageView *)mapImageView {
    if (!_mapImageView) {
        _mapImageView = [TPViewUtil imageViewWithFrame:CGRectMake(0, 0, 100, 100) image:nil];
        _mapImageView.backgroundColor = [UIColor grayColor];
    }
    return _mapImageView;
}

#pragma mark - Internal Function

- (void)scaleToFit:(BOOL)animated {
    UIImageView *view = self.mapImageView;
    if (view) {
        CGFloat scaleX = self.bounds.size.width / view.bounds.size.width;
        CGFloat scaleY = self.bounds.size.height / view.bounds.size.height;
        CGFloat scale = MIN(scaleX, scaleY);
        _scale = scale;
        if (animated) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
    
}

- (void)translate:(CGFloat)x y:(CGFloat)y {
    
}

- (void)gestureRecognizer:(UIGestureRecognizer *)gesture {
    
}

private func rotateAt(center: CGPoint, rotation: CGFloat) {
    self.gestureParams.rotation = self.gestureParams.rotation + rotation;
    // x = (x1 - x0)cosθ - (y1 - y0)sinθ + x0
    // y = (y1 - y0)cosθ + (x1 - x0)sinθ + y0
    let x1 = self.canvasView!.center.x;
    let y1 = self.canvasView!.center.y;
    let x0 = center.x;
    let y0 = self.bounds.size.height - center.y;
    let x = (x1 - x0) * cos(rotation) - (y1 - y0) * sin(rotation) + x0
    let y = (y1 - y0) * cos(rotation) + (x1 - x0) * sin(rotation) + y0;
    
    self.canvasView!.center = CGPoint(x: x, y: y);
    self.canvasView!.transform =  CGAffineTransform.identity.rotated(by: self.gestureParams.rotation).scaledBy(x: self.gestureParams.scale, y: self.gestureParams.scale);
}

private func translate(x: CGFloat, y: CGFloat) {
    self.gestureParams.translation = CGPoint(x: self.gestureParams.translation.x + x, y: self.gestureParams.translation.y + y);
    self.canvasView!.center = CGPoint(x: self.canvasView!.center.x + x, y: self.canvasView!.center.y + y);
}

@objc func gestureRecognizer(gesture: UIGestureRecognizer) {
    if self.canvasView != nil {
        switch gesture {
        case is UIPinchGestureRecognizer:
            let pinchGesture = gesture as! UIPinchGestureRecognizer;
            if pinchGesture.state == .began || pinchGesture.state == .changed {
                // 计算缩放的中心点和缩放比例，每次缩放的比例需要累计
                var center = pinchGesture.location(in: self);
                if pinchGesture.numberOfTouches == 2 {
                    let center0 = pinchGesture.location(ofTouch: 0, in: self);
                    let center1 = pinchGesture.location(ofTouch: 1, in: self);
                    center = CGPoint(x: (center0.x + center1.x)/2, y: (center0.y + center1.y)/2);
                }
                self.scaleAt(center: center, scale: pinchGesture.scale);
                pinchGesture.scale = 1;
                self.delegate?.canvasContentView(self, scale: self.gestureParams.scale);
            }
            break;
        case is UIPanGestureRecognizer:
            let panGesture = gesture as! UIPanGestureRecognizer;
            let location = panGesture.location(in: self);
            if  panGesture.state == .began {
                // 记录开始位置
                self.gestureParams.from = location;
                self.gestureParams.lastTouchs = gesture.numberOfTouches;
            }else if panGesture.state == .changed {
                if self.gestureParams.lastTouchs != panGesture.numberOfTouches {
                    self.gestureParams.from = location;
                }
                // 计算偏移量
                self.gestureParams.lastTouchs = panGesture.numberOfTouches;
                let x = location.x - self.gestureParams.from.x;
                let y = location.y - self.gestureParams.from.y;
                self.gestureParams.from = location;
                self.translate(x: x, y: y);
                self.delegate?.canvasContentView(self, x: x, y: y);
            }
            break;
        case is UIRotationGestureRecognizer:
            let rotatioGesture = gesture as! UIRotationGestureRecognizer;
            if rotatioGesture.state == .began || rotatioGesture.state == .changed {
                // 计算旋转的中心点和旋转角度，每次旋转的角度需要累计
                var center = rotatioGesture.location(in: self);
                if rotatioGesture.numberOfTouches == 2 {
                    let center0 = rotatioGesture.location(ofTouch: 0, in: self);
                    let center1 = rotatioGesture.location(ofTouch: 1, in: self);
                    center = CGPoint(x: (center0.x + center1.x)/2, y: (center0.y + center1.y)/2);
                }
                self.rotateAt(center: center, rotation: rotatioGesture.rotation);
                rotatioGesture.rotation = 0;
                self.delegate?.canvasContentView(self, rotation: self.gestureParams.rotation);
            }
            break;
        case is UITapGestureRecognizer:
            let tapGesture = gesture as! UITapGestureRecognizer;
            if tapGesture.numberOfTouches == 2 {
                self.delegate?.canvasContentView(self, tapTouches: 2);
            }else if tapGesture.numberOfTouches == 3 {
                self.delegate?.canvasContentView(self, tapTouches: 3);
            }
            break;
        default:
            break;
        }
    }
}

#pragma mark - API

- (void)setMapUrl:(NSURL *)url {
    
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
