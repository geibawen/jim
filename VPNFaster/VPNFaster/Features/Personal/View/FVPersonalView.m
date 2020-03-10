//
//  FVPersonalView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVPersonalView.h"
#import "RRUser.h"

@interface FVPersonalView() <UITextViewDelegate>


@end

@implementation FVPersonalView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addUserTableView];
    
    return self;
}

- (void)addUserTableView {
    _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    _userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _userTableView.allowsSelection = NO;
    _userTableView.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    [self addSubview:_userTableView];
}

@end
