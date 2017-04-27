//
//  ConnectPeopleViewController.m
//  SystemConnectPeople
//
//  Created by zhaoml on 2017/4/25.
//  Copyright © 2017年 赵明亮. All rights reserved.
//

#import "ConnectPeopleViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "ConnectPeopleHelper.h"
#import "FXConnectIndexView.h"
@interface ConnectPeopleViewController ()<UITableViewDelegate,UITableViewDataSource,TableViewIndexDelegate>

@property (nonatomic, copy)NSArray * titles;

@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic,strong) NSArray *keyArray;
@property (nonatomic, strong) UITableView *tableList;
/// 索引
@property (nonatomic, strong) FXConnectIndexView* tableViewIndex;

@end

@implementation ConnectPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataDic = [NSMutableDictionary dictionary];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self creatUI];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=9.0) {
        [self loadDataForNineLater];
    }else{
       [self loadDataForEight];
    }
    // Do any additional setup after loading the view.
}

- (void)creatUI {
    _tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    _tableList.delegate = self;
    _tableList.dataSource = self;
    [self.view addSubview:_tableList];
    
    self.tableViewIndex = [[FXConnectIndexView alloc] initWithFrame:CGRectMake(ScreenWidth-20,64+(ScreenHeight-64-16*_keyArray.count)/2,20,16*_keyArray.count)];
    [self.view addSubview:self.tableViewIndex];
    
}

- (void)loadDataForNineLater {
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    // 2.如果不是已经授权,则直接返回
    if (status != CNAuthorizationStatusAuthorized) {
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\nSettings>General>Privacy" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return;
    };
    // 3.获取联系人
    // 3.1.创建联系人仓库
    CNContactStore *store = [[CNContactStore alloc] init];
    
    // 3.2.创建联系人的请求对象
    // keys决定这次要获取哪些信息,比如姓名/电话
    NSArray *fetchKeys = @[CNContactGivenNameKey,CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactJobTitleKey,CNContactEmailAddressesKey,CNContactOrganizationNameKey,CNContactPostalAddressesKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    // 3.3.请求联系人
    NSError *error = nil;
    [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // stop是决定是否要停止
        FXConnectPeopleModel *model = [ConnectPeopleHelper contactDataWithCNContact:contact];
        _dataDic = [ConnectPeopleHelper getNewDictionaryForDic:_dataDic andModel:model];
        NSArray *key = [_dataDic allKeys];
        _keyArray = [ConnectPeopleHelper sortingArray:key];
        self.tableViewIndex.frame = CGRectMake(ScreenWidth-20,64+(ScreenHeight-64-16*_keyArray.count)/2,20,16*_keyArray.count);
        self.tableViewIndex.tableViewIndexDelegate = self;
        [_tableList reloadData];
    }];
}

- (void)loadDataForEight {
    //新建一个通讯录类
    int __block tip = 0;
    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
            if (!granted) {
                tip = 1;
            }
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        addressBooks = ABAddressBookCreate();
    }
    if (tip) {
        //做一个友好的提示
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\nSettings>General>Privacy" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return;
    }
    
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    [ConnectPeopleHelper addressBookDataWithCNContact:allPeople andNumber:nPeople andBlock:^(NSMutableDictionary *array) {
        _dataDic = array;
        NSArray *key = [_dataDic allKeys];
        _keyArray = [ConnectPeopleHelper sortingArray:key];
        self.tableViewIndex.frame = CGRectMake(ScreenWidth-20,64+(ScreenHeight-64-16*_keyArray.count)/2,20,16*_keyArray.count);
        self.tableViewIndex.tableViewIndexDelegate = self;
        [_tableList reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *valueArr = _dataDic[_keyArray[section]];
    return valueArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iden"];
    if (!cell) {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"iden"];
    }
    NSArray *arr = [_dataDic objectForKey:_keyArray[indexPath.section]];
    FXConnectPeopleModel *model = arr[indexPath.row];
    cell.textLabel.text = model.name.length==0?model.phoneNumber:model.name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    label.text = _keyArray[section];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [_dataDic objectForKey:_keyArray[indexPath.section]];
    FXConnectPeopleModel *model = arr[indexPath.row];
       NSLog(@"+++++name == %@\nphone ==%@\n email===%@\npositon==%@\ncompanyn===%@\ncompanya===%@",model.name,model.phoneNumber,model.email,model.position,model.companyName,model.companyAddress);
}


- (void)tableViewIndexTouchesBegan:(FXConnectIndexView *)tableViewIndex {
    
}

- (void)tableViewIndexTouchesEnd:(FXConnectIndexView *)tableViewIndex
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
}
- (NSArray *)tableViewIndexTitle:(FXConnectIndexView *)tableViewIndex {
    NSLog(@"_keyArray === %@",_keyArray);
    return _keyArray;
}

- (void)tableViewIndex:(FXConnectIndexView *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title {
    if ([_tableList numberOfSections] > index && index > -1){
        
        [_tableList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                        atScrollPosition:UITableViewScrollPositionTop
                                animated:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
