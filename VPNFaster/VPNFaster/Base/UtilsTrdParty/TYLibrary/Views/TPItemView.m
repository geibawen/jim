//
//  TPItemView.m
//  TuyaSmart
//
//  Created by fengyu on 15/9/6.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import "TPItemView.h"
#import "TPViewUtil.h"
#import "TPViews.h"

typedef enum {
    TPItemViewImagePositionLeft = 1,
    TPItemViewImagePositionCenter,
    TPItemViewImagePositionRightArrow,
    TPItemViewImagePositionRightLeft,
} TPItemViewImagePosition;


@interface TPItemView()



@end

@implementation TPItemView

+ (TPItemView *)itemViewWithFrame:(CGRect)frame {
    return [[TPItemView alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = LIST_BACKGROUND_COLOR;
        [self addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(itemViewTap)]];
    }
    return self;
}

- (void)itemViewTap {
    if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [self customLine:CGPointMake(0, 0) width:self.width color:LIST_LINE_COLOR];
        [self addSubview:_topLine];
    }
    return _topLine;
}

- (UIView *)middleLine {
    if (!_middleLine) {
        _middleLine = [self customLine:CGPointMake(20, self.frame.size.height-0.5) width:self.width-20 color:LIST_LINE_COLOR];
        [self addSubview:_middleLine];
    }
    return _middleLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [self customLine:CGPointMake(0, self.frame.size.height-0.5) width:self.width color:LIST_LINE_COLOR];
        [self addSubview:_bottomLine];
    }
    return _bottomLine;
}

- (UIView *)customLine:(CGPoint)origin width:(float)width color:(UIColor *)color {
    return [TPViewUtil viewWithFrame:CGRectMake(origin.x, origin.y, width, 0.5) color:color];
}

- (void)showTopLine {
    self.topLine.hidden = NO;
}

- (void)showMiddleLine {
    self.middleLine.hidden = NO;
}

- (void)showBottomLine {
    self.bottomLine.hidden = NO;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
//        UIView *labelView = [TPViewUtil viewWithFrame:CGRectMake(0, 0.5, 250, self.height-1) color:nil];
        
        _leftLabel = [TPViewUtil labelWithFrame:CGRectMake(0, 0, 250, self.height) fontSize:17 color:LIST_MAIN_TEXT_COLOR];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        
        _leftLabel.userInteractionEnabled = YES;
        [_leftLabel addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(leftLabelTap)]];
        [self addSubview:_leftLabel];
        
//        [labelView addSubview:_leftLabel];
//        [labelView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(leftLabelTap)]];
//        [self addSubview:labelView];
    }
    return _leftLabel;
}

- (UILabel *)leftSubLabel {
    if (!_leftSubLabel) {
        if (_leftLabel) {
            _leftLabel.top = 0;
            _leftLabel.height = 40;
        }
//        UIView *labelView = [TPViewUtil viewWithFrame:CGRectMake(0, 0.5, 250, self.height-1) color:nil];
        
        _leftSubLabel = [TPViewUtil labelWithFrame:CGRectMake(0, self.height / 2, 250, 24) fontSize:14 color:LIST_SUB_TEXT_COLOR];
        _leftSubLabel.adjustsFontSizeToFitWidth = YES;
        
        _leftSubLabel.userInteractionEnabled = YES;
        [_leftSubLabel addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(leftLabelTap)]];
        [self addSubview:_leftSubLabel];
        
//        [labelView addSubview:_leftSubLabel];
//        [labelView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(leftLabelTap)]];
//        [self addSubview:labelView];
    }
    return _leftSubLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
//        UIView *labelView = [TPViewUtil viewWithFrame:CGRectMake(self.width - 150, 0.5, 150, self.height-1) color:nil];
        
        NSInteger rightForArrowSpace = self.rightArrow.hidden == YES ? 0 : 15;
        _rightLabel = [TPViewUtil labelWithFrame:CGRectMake(self.width - 300 - 20 - rightForArrowSpace,0,300, self.height) fontSize:15 color:LIST_SUB_TEXT_COLOR];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        
        _rightLabel.userInteractionEnabled = YES;
        [_rightLabel addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightLabelTap)]];
        [self addSubview:_rightLabel];
        
//        [labelView addSubview:_rightLabel];
//        [labelView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightLabelTap)]];
//        [self addSubview:labelView];
    }
    return _rightLabel;
}

- (UILabel *)rightSubLabel {
    if (!_rightSubLabel) {
        if (_rightLabel) {
            _rightLabel.top = self.height / 2 - 22;
            _rightLabel.height = 22;
        }
        NSInteger rightForArrowSpace = self.rightArrow.hidden == YES ? 0 : 15;
        _rightSubLabel = [TPViewUtil labelWithFrame:CGRectMake(self.width - 150 - 20 - rightForArrowSpace,self.height / 2,150, 22) fontSize:15 color:LIST_SUB_TEXT_COLOR];
        _rightSubLabel.textAlignment = NSTextAlignmentRight;
        _rightSubLabel.adjustsFontSizeToFitWidth = YES;
        
        _rightSubLabel.userInteractionEnabled = YES;
        [_rightSubLabel addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightLabelTap)]];
        [self addSubview:_rightSubLabel];
        
        //        [labelView addSubview:_rightLabel];
        //        [labelView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightLabelTap)]];
        //        [self addSubview:labelView];
    }
    return _rightSubLabel;
}

- (void)setRightLabelWidth:(float)width {
    UIView *labelView = self.rightLabel.superview;
    labelView.frame = CGRectMake(self.width-width, 0.5, width, self.height-1);
    self.rightLabel.frame = CGRectMake(0,0, width-35,labelView.height);
}

- (UILabel *)centerLabel {
    if (!_centerLabel) {
        UIView *labelView = [TPViewUtil viewWithFrame:CGRectMake((self.width - 150)/2, 0.5, 150, self.height-1) color:nil];
        
        _centerLabel = [TPViewUtil labelWithFrame:CGRectMake(0,0,150,self.height) fontSize:18 color:LIST_MAIN_TEXT_COLOR];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.adjustsFontSizeToFitWidth = YES;
        
        [labelView addSubview:_centerLabel];
        [labelView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(centerLabelTap)]];
        [self addSubview:labelView];
    }
    return _centerLabel;
}

- (void)leftLabelTap {
    if ([self.delegate respondsToSelector:@selector(itemViewLeftLabelTap:)]) {
        [self.delegate itemViewLeftLabelTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (void)centerLabelTap {
    if ([self.delegate respondsToSelector:@selector(itemViewCenterLabelTap:)]) {
        [self.delegate itemViewCenterLabelTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (void)rightLabelTap {
    if ([self.delegate respondsToSelector:@selector(itemViewRightLabelTap:)]) {
        [self.delegate itemViewRightLabelTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (UIImageView *) rightArrow {
    if (!_rightArrow) {
        _rightArrow = [self imageViewForItemView:TPItemViewImagePositionRightArrow image:[UIImage imageNamed:@"tp_list_arrow_goto"]];
        [self addSubview:_rightArrow];
    }
    return _rightArrow;
}

- (void)showRightArrow {
    self.rightArrow.hidden = NO;
}

- (void)setLeftImage:(UIImage *)leftImage {
    _leftImageView = [self imageViewForItemView:TPItemViewImagePositionLeft image:leftImage];
    [_leftImageView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(leftImageViewTap)]];
    [self addSubview:_leftImageView];
}

- (void)setCenterImage:(UIImage *)centerImage {
    _centerImageView = [self imageViewForItemView:TPItemViewImagePositionCenter image:centerImage];
    [_centerImageView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(centerImageViewTap)]];
    if (_leftLabel) {
        CGFloat titleWidth =  [self.leftLabel.text sizeWithAttributes:@{NSFontAttributeName : self.leftLabel.font}].width;
        _centerImageView.left = _leftLabel.left + titleWidth + 15;
    }
    
    [self addSubview:_centerImageView];
}

- (void)setRightImage:(UIImage *)rightImage {
    if (!_rightImageView) {
        _rightImageView = [self imageViewForItemView:TPItemViewImagePositionRightLeft image:rightImage];
        [_rightImageView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightImageViewTap)]];
        [self addSubview:_rightImageView];
    }
}

- (void)setRightImageUrl:(NSString *)rightImageUrl {
    if (!_rightImageView) {
        float rightInset = 20;
        if (!self.rightArrow.hidden == YES) {
            rightInset = 20 + 15;
        }
        _rightImageView = [TPViewUtil imageViewWithFrame:CGRectMake(self.frame.size.width - 25 - rightInset, (self.frame.size.height - 25)/2, 25, 25) imageName:nil];
        
        [_rightImageView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(rightImageViewTap)]];
        [self addSubview:_rightImageView];
    }
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageUrl]];
}

- (void)setRightImageArray:(NSArray *)rightImageArray {
    float rightInset = 20;
    if (!self.rightArrow.hidden == YES) {
        rightInset = 20 + 15;
    }
    for (int i = rightImageArray.count - 1; i >= 0; i--) {
        UIImageView  *rightImageView = [TPViewUtil imageViewWithFrame:CGRectMake(self.frame.size.width - 25 - rightInset - i*28, (self.frame.size.height - 25)/2, 25, 25) imageName:rightImageArray[i]];
        [self addSubview:rightImageView];
    }
}

- (UIImageView *)imageViewForItemView:(TPItemViewImagePosition)position image:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect frame = imageView.frame;
    
    switch (position) {
        case TPItemViewImagePositionCenter : {
            frame.origin = CGPointMake((self.frame.size.width-frame.size.width)/2, (self.frame.size.height -frame.size.height)/2);
            break;
        }
        case TPItemViewImagePositionRightArrow : { //This is for right arrow
            frame.origin = CGPointMake(self.frame.size.width - frame.size.width - 20, (self.frame.size.height -frame.size.height)/2);
            break;
        }
        case TPItemViewImagePositionRightLeft : {
            float rightInset = 20;
            if (!self.rightArrow.hidden == YES) {
                rightInset = 20 + 15;
            }
            frame.origin = CGPointMake(self.frame.size.width - frame.size.width - rightInset, (self.frame.size.height -frame.size.height)/2);
            break;
        }
        default : {
            frame.origin = CGPointMake(20, (self.frame.size.height -frame.size.height)/2);
            break;
        }
    }
    
    imageView.frame = frame;
    return imageView;
}

- (void)leftImageViewTap {
    if ([self.delegate respondsToSelector:@selector(itemViewLeftImageTap:)]) {
        [self.delegate itemViewLeftImageTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (void)centerImageViewTap {
    if ([self.delegate respondsToSelector:@selector(itemViewCenterImageTap:)]) {
        [self.delegate itemViewCenterImageTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (void)rightImageViewTap {
    if ([self.delegate respondsToSelector:@selector(itemViewRightImageTap:)]) {
        [self.delegate itemViewRightImageTap:self];
    } else if ([self.delegate respondsToSelector:@selector(itemViewTap:)]) {
        [self.delegate itemViewTap:self];
    }
}

- (void)showSwitchBtn {
    _switchBtn = [[UISwitch alloc] init];
    _switchBtn.left = self.width - _switchBtn.width - 15;
    _switchBtn.top = (self.height - _switchBtn.height)/2;
    [self addSubview:_switchBtn];
}

@end
