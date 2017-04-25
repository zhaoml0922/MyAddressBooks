//
//  AppDelegate.h
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/25.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

