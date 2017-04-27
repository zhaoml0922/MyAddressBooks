//
//  FXConnectIndexView.h
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/26.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TableViewIndexDelegate;


@interface FXConnectIndexView : UIView

@property (nonatomic, strong) NSArray *indexes;

@property (nonatomic, weak) id <TableViewIndexDelegate> tableViewIndexDelegate;
@end

@protocol TableViewIndexDelegate <NSObject>

/**
 触摸到索引时触发
 
 @param tableViewIndex 触发didSelectSectionAtIndex对象
 @param index 索引下标
 @param title 索引文字
 */
- (void)tableViewIndex:(FXConnectIndexView *)tableViewIndex
didSelectSectionAtIndex:(NSInteger)index
             withTitle:(NSString *)title;


/**
 开始触摸索引

 @param tableViewIndex 触发tableViewIndexTouchesBegan对象
 */
- (void)tableViewIndexTouchesBegan:(FXConnectIndexView *)tableViewIndex;



/**
 触摸索引结束

 @param tableViewIndex index
 */
- (void)tableViewIndexTouchesEnd:(FXConnectIndexView *)tableViewIndex;


/**
 TableView中右边右边索引title

 @param tableViewIndex 触发tableViewIndexTitle对象
 @return 索引title数组
 */
- (NSArray *)tableViewIndexTitle:(FXConnectIndexView *)tableViewIndex;






@end
