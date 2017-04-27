//
//  ConnectPeopleHelper.h
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/25.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXConnectPeopleModel.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ConnectPeopleHelper : NSObject

/**
 系统联系人返回数据的处理 9.0之后
 
 @param contact 系统联系人
 */
+ (FXConnectPeopleModel *)contactDataWithCNContact:(CNContact *)contact;


/**
 系统联系人返回数据的处理 9.0之前

 @param allPeople 系统联系人数组
 @param nPeople 个数
 @param block 返回
 */
+ (void)addressBookDataWithCNContact:(CFArrayRef )allPeople
                           andNumber:(CFIndex )nPeople
                        andBlock:(void (^)(NSMutableDictionary *array))block;


/**
 字典分组

 @param dict 字典
 @param model 模型
 @return 分组后的字典
 */
+ (NSMutableDictionary *)getNewDictionaryForDic:(NSMutableDictionary *)dict
                                       andModel:(FXConnectPeopleModel *)model;


/**
 数组排序

 @param array 数组
 @return 排序后的数组
 */
+ (NSArray *)sortingArray:(NSArray *)array;

@end
