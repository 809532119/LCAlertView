//
//  KKAlertView.h
//  TestAlert
//
//  Created by 刘冲 on 2020/4/14.
//  Copyright © 2020 Konke. All rights reserved.
//

#import <UIKit/UIKit.h>

//弹框类型
typedef NS_ENUM(NSInteger, KKAlertViewStyle) {
    KKAlertViewStyleAlert,    //中间弹出
    KKAlertViewStyleActionSheet    //底部弹出
};
typedef void (^KKHandlerBlock)(NSInteger index);

@interface LCAlertView : UIView
@property (nonatomic,assign,readonly) KKAlertViewStyle style;
@property (nonatomic,strong) UIColor *otherTitleColor;
@property (nonatomic,assign,readonly) BOOL isShowing; //是否正在显示

//初始化方法
-(instancetype)initWithStyle:(KKAlertViewStyle)style
                       title:(NSString *)title
                     message:(NSString *)message
                 cancelTitle:(NSString *)cancelTitle
                 otherTitles:(NSArray *)otherTitles
                     handler:(KKHandlerBlock)handler;

//显示，默认添加到当前的window
-(void)show;
@end
