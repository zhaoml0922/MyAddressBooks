//
//  ConnectPeopleHelper.m
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/25.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import "ConnectPeopleHelper.h"

@implementation ConnectPeopleHelper


+ (FXConnectPeopleModel *)contactDataWithCNContact:(CNContact *)contact {
    FXConnectPeopleModel *model = [[FXConnectPeopleModel alloc] init];
    // 1.获取联系人的姓名
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    model.name = [NSString stringWithFormat:@"%@%@",lastname,firstname];
    
    // 2.获取联系人的电话号码(此处获取的是该联系人的第一个号码,也可以遍历所有的号码)
    NSArray *phoneNums = contact.phoneNumbers;
    NSString *phoneNumber = @"";
    if ([phoneNums count]!=0) {
        CNLabeledValue *labeledValue = phoneNums[0];
        CNPhoneNumber *phoneNumer = labeledValue.value;
        phoneNumber = phoneNumer.stringValue;
    }
    NSArray *arr = [[NSString stringWithFormat:@"%@",phoneNumber] componentsSeparatedByString:@"-"];
    NSString *phoneString = [arr componentsJoinedByString:@""];
    model.phoneNumber = phoneString;
    
    ///3获取联系人的邮箱
    NSArray *emailAddresses = contact.emailAddresses;
    NSString *email = @"";
    if ([emailAddresses count]!=0) {
        CNLabeledValue *labeledValue = emailAddresses[0];
        email = labeledValue.value;
    }
    model.email = email;
    
    ///4获取联系人职位
    NSString *jobTitle = (contact.jobTitle.length==0 || contact.jobTitle==nil || [contact.jobTitle isKindOfClass:[NSNull class]])?@"":contact.jobTitle;
    model.position = jobTitle;
    
    ////5获取联系人公司名称
    NSString *companyName = (contact.organizationName.length==0 || contact.organizationName==nil || [contact.organizationName isKindOfClass:[NSNull class]])?@"":contact.organizationName;
    model.companyName = companyName;
    
    ////6获取联系人公司地址
    NSArray *addressArr = contact.postalAddresses;
    NSString *addressStr = @"";
    if (addressArr.count != 0) {
        CNLabeledValue *labeledValues = addressArr[0];
        CNPostalAddress *address = labeledValues.value;
        addressStr = [NSString stringWithFormat:@"%@%@%@",address.state,address.city,address.street];
    }
    model.companyAddress = addressStr;
    return model;
}


+ (void)addressBookDataWithCNContact:(CFArrayRef )allPeople
                           andNumber:(CFIndex)nPeople
                            andBlock:(void (^)(NSMutableDictionary *))block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (int i=0; i<nPeople; i++) {
        FXConnectPeopleModel *model = [[FXConnectPeopleModel alloc] init];

        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        ////姓名
        NSString *name = @"";
        NSString *personName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        name = [NSString stringWithFormat:@"%@%@",personName,lastname];
        model.name = name;
        
        ///电话号
        NSString *phoneNumber = @"";
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phone)>0) {
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        model.phoneNumber = phoneNumber;
        
        ////email
        NSString *emailString = @"";
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        if (ABMultiValueGetCount(email)>0) {
            emailString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, 0);
        }
        model.email = emailString;
        
        
        ///4获取联系人职位
        
        NSString *position = (__bridge NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        model.position = position;
        
        ////5获取联系人公司名称
        NSString *organization = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        model.companyName = organization;
        
        ////6获取联系人公司地址
        NSString *addressStr = @"";
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        if (ABMultiValueGetCount(address)>0) {
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, 0);
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            addressStr = [NSString stringWithFormat:@"%@%@%@",state,city,street];
        }
        model.companyAddress = addressStr;
        
        dict = [ConnectPeopleHelper getNewDictionaryForDic:dict andModel:model];
    }
    block(dict);
}


+ (NSMutableDictionary *)getNewDictionaryForDic:(NSMutableDictionary *)dict andModel:(FXConnectPeopleModel *)model {
    NSMutableString *ms = [[NSMutableString alloc]initWithString:model.name];
    if (model.name.length != 0) {
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformMandarinLatin, NO)) {
            NSLog(@"pinyin: ---- %@", ms);
        }
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformStripDiacritics, NO)) {
            
            NSString *bigStr = [ms uppercaseString]; // bigStr 是转换成功后的拼音
            NSString *cha = [bigStr substringToIndex:1];
            NSLog(@"汉字=====%@",cha);
            NSMutableArray *arr = [NSMutableArray array];
            if ([[dict allKeys] containsObject:cha]) {
                arr = [dict[cha] mutableCopy];
                [arr addObject:model];
                [dict setObject:arr forKey:cha];
            } else {
                [arr addObject:model];
                [dict setObject:arr forKey:cha];
            }
        }
    }else{
        NSString *cha = @"#";
        NSMutableArray *arr = [NSMutableArray array];
        if ([[dict allKeys] containsObject:cha]) {
            arr = [dict[cha] mutableCopy];
            [arr addObject:model];
            [dict setObject:arr forKey:cha];
        } else {
            [arr addObject:model];
            [dict setObject:arr forKey:cha];
        }
    }
    return dict;
}


+ (NSArray *)sortingArray:(NSArray *)array {
    NSMutableArray *arr = [array mutableCopy];
    for (int i=0; i<arr.count-1; i++) {
        for (int j = 0; j<arr.count - 1; j++) {
            if ([arr[j] compare:arr[j+1]]>0) {
                [arr exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    }
    NSLog(@"keyArr === %@",arr);
    return arr;
}

@end
