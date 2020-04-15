//
//  KKAlertView.m
//  TestAlert
//
//  Created by 刘冲 on 2020/4/14.
//  Copyright © 2020 Konke. All rights reserved.
//

#import "LCAlertView.h"

#define DEVICE_IS_IPHONEX       ([[UIScreen mainScreen] bounds].size.height == 812 || [[UIScreen mainScreen] bounds].size.height == 896)
static const NSInteger kButtonTag = 100;  //取消按钮100，其他101开始
@interface LCAlertView (){
    NSString *_title;
    NSString *_message;
    NSString *_cancelTitle;
    NSArray *_otherTitles;
    KKHandlerBlock _handler;
}
@property (nonatomic,strong) UIView *maskView; //阴影遮罩
@property (nonatomic,strong) UIScrollView *mainView; //主视图
@property (nonatomic,strong) NSArray<UIButton *> *buttons;
@end

@implementation LCAlertView{
    CGFloat kDuration; //动画时长
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    CGFloat _mainViewLeft;
    CGFloat _lineViewH;
    
    CGFloat _sheetItemH;
    CGFloat _sheetItemLeftMargin;
    CGFloat _sheetItemSectionMargin;
}
-(instancetype)initWithStyle:(KKAlertViewStyle)style title:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles handler:(KKHandlerBlock)handler {
    if(self = [super init]){
        _style = style;
        _title = title;
        _message = message;
        _cancelTitle = cancelTitle;
        _otherTitles = [NSArray arrayWithArray:otherTitles];
        _handler = handler;
        
        [self initData];
        [self layoutUI];
    }
    return self;
}

//显示
-(void)show {
    _isShowing = YES;
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window endEditing:YES];
    [window addSubview:self];
    
    if(_style == KKAlertViewStyleAlert){
        [UIView animateWithDuration:kDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:0 animations:^{
            self.maskView.alpha = 0.35;
            self.mainView.alpha = 1;
            self.mainView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        CGRect mainViewFrame = self.mainView.frame;
        mainViewFrame.origin.y = _screenHeight - mainViewFrame.size.height;
        [UIView animateWithDuration:kDuration animations:^{
            self.maskView.alpha = 0.35;
            self.mainView.frame = mainViewFrame;
        }];
    }
}

//隐藏
-(void)hide {
    if(_style == KKAlertViewStyleAlert){
        [UIView animateWithDuration:kDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:0 animations:^{
            self.maskView.alpha = 0;
            self.mainView.alpha = 0;
            self.mainView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            self->_isShowing = NO;
        }];
    }else{
        CGRect mainViewFrame = self.mainView.frame;
        mainViewFrame.origin.y = _screenHeight;
        [UIView animateWithDuration:kDuration animations:^{
            self.maskView.alpha = 0;
            self.mainView.frame = mainViewFrame;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
            self->_isShowing = NO;
        }];
    }
}

-(void)click:(UIButton *)sender {
    [self hide];
    NSInteger tag = sender.tag;
    NSInteger index = 0;
    if(tag == kButtonTag){
        index = 0;
    }else{
        index = _cancelTitle.length ? tag - kButtonTag : tag - kButtonTag - 1;
    }
    _handler(index);
}

-(void)setOtherTitleColor:(UIColor *)otherTitleColor {
    _otherTitleColor = otherTitleColor;
    [self.buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.tag != kButtonTag){
            [obj setTitleColor:_otherTitleColor forState:UIControlStateNormal];
        }
    }];
}

-(void)initData {
    kDuration = _style == KKAlertViewStyleAlert ? 0.5f : 0.3f;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _lineViewH = 1.0 / [UIScreen mainScreen].scale;
    if(_style == KKAlertViewStyleAlert){
        _mainViewLeft = _screenWidth / 7.0;
    }else{
        _sheetItemH = 55.f;
        _sheetItemLeftMargin = 10.f;
        _sheetItemSectionMargin = 10.f;
    }
}
//视图绘制
-(void)layoutUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = UIColor.clearColor;
    
    self.maskView = [[UIView alloc]initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.maskView];
    self.maskView.alpha = 0;
    
    NSMutableArray *buttons = [NSMutableArray array];
    if(_style == KKAlertViewStyleAlert){
        self.mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(_mainViewLeft, 0, _screenWidth - _mainViewLeft * 2, 0)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        self.mainView.layer.cornerRadius = 5;
        self.mainView.layer.masksToBounds = YES;
        [self addSubview:self.mainView];
        
        CGFloat bottomY = 20;
        UILabel *titleLabel = nil;
        if(_title.length){
            UIFont *titleFont = [UIFont boldSystemFontOfSize:17];
            UIColor *titleColor = [UIColor blackColor];
            titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, self.mainView.frame.size.width - 10 * 2, 0)];
            CGRect titleRect = [_title boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleFont} context:nil];
            CGRect titleFrame = titleLabel.frame;
            titleFrame.size.height = titleRect.size.height;
            titleLabel.frame = titleFrame;
            titleLabel.textColor = titleColor;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.numberOfLines = 0;
            titleLabel.text = _title;
            [self.mainView addSubview:titleLabel];
            bottomY = CGRectGetMaxY(titleLabel.frame) + 20;
        }
        
        UILabel *msgLabel = nil;
        if(_message.length){
            UIFont *msgFont = [UIFont boldSystemFontOfSize:15];
            UIColor *msgColor = [UIColor blackColor];
            CGFloat msgLabelY = titleLabel ? CGRectGetMaxY(titleLabel.frame) + 20 : 20;
            msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, msgLabelY, self.mainView.frame.size.width - 10 * 2, 0)];
            CGRect msgRect = [_message boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : msgFont} context:nil];
            CGRect msgFrame = msgLabel.frame;
            msgFrame.size.height = msgRect.size.height;
            msgLabel.frame = msgFrame;
            msgLabel.textColor = msgColor;
            msgLabel.font = msgFont;
            msgLabel.textAlignment = NSTextAlignmentCenter;
            msgLabel.numberOfLines = 0;
            msgLabel.text = _message;
            [self.mainView addSubview:msgLabel];
            bottomY = CGRectGetMaxY(msgLabel.frame) + 20;
        }
        
        UIView *lineView = [self lineViewWithFrame:CGRectMake(0, bottomY, self.mainView.frame.size.width, _lineViewH)];
        [self.mainView addSubview:lineView];
        
        BOOL hasTwoButton = NO;
        if(_cancelTitle.length){
            if(_otherTitles.count == 1){
                hasTwoButton = YES;
            }
        }else{
            if(_otherTitles.count == 2){
                hasTwoButton = YES;
            }
        }
        
        NSMutableArray *titles = [NSMutableArray new];
        if(_cancelTitle.length){
            [titles addObject:_cancelTitle];
        }
        if(_otherTitles.count){
            [titles addObjectsFromArray:_otherTitles];
        }
        
        CGFloat buttonH = 40.f;
        if(hasTwoButton){
            UIView *mLineView = [self lineViewWithFrame:CGRectMake((self.mainView.frame.size.width - 1.0 / [UIScreen mainScreen].scale) * 0.5, CGRectGetMaxY(lineView.frame), _lineViewH, buttonH)];
            [self.mainView addSubview:mLineView];
            for (int i = 0;i<titles.count;i++) {
                CGFloat x = i == 0 ? 0 : CGRectGetMaxX(mLineView.frame);
                CGFloat y = CGRectGetMaxY(lineView.frame);
                CGFloat w = (self.mainView.frame.size.width - 1.0 / [UIScreen mainScreen].scale) * 0.5;
                CGFloat h = buttonH;
                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, w, h)];
                btn.titleLabel.font = [UIFont systemFontOfSize:17];
                
                [btn setTitleColor:[UIColor colorWithRed:87/255.0 green:88/255.0 blue:89/255.0 alpha:1] forState:UIControlStateNormal];
                [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
                if(_cancelTitle.length){
                    btn.tag = i == 0 ? kButtonTag : kButtonTag + i;
                }else{
                    btn.tag = kButtonTag + 1 + i;
                }
                [self.mainView addSubview:btn];
                [buttons addObject:btn];
            }
        }else{
            for (int i = 0;i<titles.count;i++) {
                UIButton *lastBtn = [buttons lastObject];
                CGFloat x = 0;
                CGFloat y = lastBtn ? CGRectGetMaxY(lastBtn.frame) : CGRectGetMaxY(lineView.frame);
                if(i != 0){
                    y += _lineViewH;
                }
                CGFloat w = self.mainView.frame.size.width;
                CGFloat h = buttonH;
                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, w, h)];
                btn.titleLabel.font = [UIFont systemFontOfSize:17];

                [btn setTitleColor:[UIColor colorWithRed:87/255.0 green:88/255.0 blue:89/255.0 alpha:1] forState:UIControlStateNormal];
                [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
                [btn setTitle:titles[i] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
                if(_cancelTitle.length){
                    btn.tag = i == 0 ? kButtonTag : kButtonTag + i;
                }else{
                    btn.tag = kButtonTag + 1 + i;
                }
                [self.mainView addSubview:btn];
                [buttons addObject:btn];
                
                if(i != titles.count - 1){
                    UIView *rLineView = [self lineViewWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame), w, _lineViewH)];
                    [self.mainView addSubview:rLineView];
                }
            }
        }
        
        self.buttons = [NSArray arrayWithArray:buttons];
        UIButton *btn = [buttons lastObject];
        CGFloat realHeight = CGRectGetMaxY(btn.frame);
        CGFloat maxHeight = DEVICE_IS_IPHONEX ? (_screenHeight - 34 * 2) : (_screenHeight - 20 * 2);
        CGRect mainViewRect = self.mainView.frame;
        mainViewRect.size.height = realHeight < maxHeight ? realHeight : maxHeight;
        mainViewRect.origin.y = (_screenHeight - mainViewRect.size.height) * 0.5;
        self.mainView.frame = mainViewRect;
        self.mainView.contentSize = CGSizeMake(0, realHeight);
        
        self.mainView.alpha = 0;
        self.mainView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self.maskView addGestureRecognizer:tap];
        
        CGFloat containerH = 0;
        CGFloat realContainerH = 0;
        CGFloat bottomH = DEVICE_IS_IPHONEX ? 34.f : 10.f;
        CGFloat mainViewH = 0;
        CGFloat itemW = _screenWidth - _sheetItemLeftMargin * 2;
        mainViewH += _otherTitles.count * _sheetItemH;
        mainViewH += (_otherTitles.count - 1) * _lineViewH;
        if(_title.length || _message.length){
            mainViewH += _sheetItemH;
            mainViewH += _lineViewH;
        }
        containerH = mainViewH;
        realContainerH = containerH;
        CGFloat containerViewMaxH = _screenHeight - bottomH - (_cancelTitle.length ? _sheetItemH : 0) - _sheetItemSectionMargin - (DEVICE_IS_IPHONEX ? 44 : 20);
        containerH = containerH < containerViewMaxH ? containerH : containerViewMaxH;
        mainViewH = containerH;
        if(_cancelTitle.length){
            mainViewH += _sheetItemSectionMargin;
            mainViewH += _sheetItemH;
        }
        mainViewH += bottomH;
        
        UIScrollView *containerView = [[UIScrollView alloc]initWithFrame:CGRectMake(_sheetItemLeftMargin, 0, itemW, containerH)];
        containerView.contentSize = CGSizeMake(0, realContainerH);
        containerView.layer.cornerRadius = 10.f;
        containerView.layer.masksToBounds = YES;
        containerView.backgroundColor = [UIColor whiteColor];
        
        self.mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _screenHeight, _screenWidth, mainViewH)];
        self.mainView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mainView];
    
        [self.mainView addSubview:containerView];
        
        CGFloat buttonsY = 0;
        if(_title.length || _message.length){
            buttonsY = _sheetItemH;
            UIView *msgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, itemW, _sheetItemH)];
            msgView.layer.cornerRadius = 5.f;
            msgView.layer.masksToBounds = YES;
            [containerView addSubview:msgView];
            
            CGFloat h = 19;
            UILabel *titleLabel = nil;
            if(_title.length){
                CGFloat titleY = _message.length ? (_sheetItemH - h * 2) * 0.5 : (_sheetItemH - h) * 0.5;
                titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, titleY, itemW - 10 * 2, h)];
                titleLabel.textColor = UIColor.grayColor;
                titleLabel.font = [UIFont systemFontOfSize:14.0];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.text = _title;
                [msgView addSubview:titleLabel];
            }
            
            UILabel *msgLabel = nil;
            if(_message.length){
                CGFloat messageY = _title.length ? CGRectGetMaxY(titleLabel.frame) : (_sheetItemH - h) * 0.5;
                msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, messageY, itemW - 10 * 2, h)];
                msgLabel.textColor = UIColor.grayColor;
                msgLabel.font = [UIFont systemFontOfSize:14.0];
                msgLabel.textAlignment = NSTextAlignmentCenter;
                msgLabel.text = _message;
                [msgView addSubview:msgLabel];
            }
        }
        
        BOOL hasTopTitle = _title.length || _message.length;
        for(int i=0;i<_otherTitles.count;i++){
            UIButton *lastBtn = [buttons lastObject];
            UIView *lineView = nil;
            if((!hasTopTitle && i != 0) || hasTopTitle){
                lineView = [self lineViewWithFrame:CGRectMake(0, lastBtn ? CGRectGetMaxY(lastBtn.frame) + buttonsY : buttonsY, itemW, _lineViewH)];
                [containerView addSubview:lineView];
            }
            
            CGFloat x = 0;
            CGFloat y = lineView ? CGRectGetMaxY(lineView.frame) : buttonsY;
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, itemW, _sheetItemH)];
            btn.backgroundColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];

            [btn setTitleColor: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
            [btn setTitle:_otherTitles[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = kButtonTag + 1 + i;
            [containerView addSubview:btn];
            [buttons addObject:btn];
        }
        
        if(_cancelTitle.length){
            UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(_sheetItemLeftMargin, mainViewH - bottomH - _sheetItemH, itemW, _sheetItemH)];
            cancelBtn.layer.cornerRadius = 10.f;
            cancelBtn.layer.masksToBounds = YES;
            cancelBtn.backgroundColor = [UIColor whiteColor];
            cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];

            [cancelBtn setTitleColor: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
            [cancelBtn setTitle:_cancelTitle forState:UIControlStateNormal];
            [cancelBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            cancelBtn.tag = kButtonTag;
            [self.mainView addSubview:cancelBtn];
            [buttons addObject:cancelBtn];
        }
        self.buttons = [NSArray arrayWithArray:buttons];
    }
}

//线条
-(UIView *)lineViewWithFrame:(CGRect)frame {
    UIView *lineView = [[UIView alloc]initWithFrame:frame];
    lineView.backgroundColor = [UIColor colorWithRed:179/255.0 green:178/255.0 blue:178/255.0 alpha:1];
    return lineView;
}

-(UIImage *)createImageWithColor:(UIColor*)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
