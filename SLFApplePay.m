//
//  SLFApplePay.m
//  ApplePayText
//
//  Created by SADF on 17/2/17.
//  Copyright © 2017年 LingFeng. All rights reserved.
//

#import "SLFApplePay.h"
static SLFApplePay * ap = nil;
@implementation SLFApplePay

+(SLFApplePay *)share {
    @synchronized(self) {
        if (ap == nil) {
            //重写 alloc
            ap = [[super allocWithZone:NULL]init];
        }
        return ap;
    }
}

//重写 alloc
+(id)allocWithZone:(struct _NSZone *)zone{
    return [self share];
}
//重写 copy
+(id)copyWithZone:(struct _NSZone *)zone{
    return self;
}

+(void)startApplePay:(UIViewController *)vc items:(NSArray <SLFAPPaymentSummaryItem *> *)items shipping:(NSArray <SLFAPShippingMethod *> *)shipping {
    //首先判断设备是否支持Apple Pay快捷支付功能
    
    /**
     *  canMakePayments(BOOL) YES 代表设备支持applePay功能 否则不支持
     *  若是用户设备不能进行支付，则不要显示支付按钮，相应的应该退回到其它支付方式(支付宝 微信等)
     *  我这里是直接让其返回 不做其他操作
     */
    if (![PKPaymentAuthorizationViewController canMakePayments]) return;
    
//    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
//    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"收款商户" amount:[NSDecimalNumber decimalNumberWithString:@"1"]];   // 金额
//    
//    request.paymentSummaryItems = @[total];
//    request.countryCode = @"CN";    // process支付的中国
//    request.currencyCode = @"CNY"; // 金额展示为人民币格式
//    request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay];  // 中国银联
//    request.merchantIdentifier = @"merchant.com.ztd.applepaytest";
//    request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
//    
//    PKPaymentAuthorizationViewController *paymentSheet = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
//    if (paymentSheet) {
//        [vc presentViewController:paymentSheet animated:YES completion:nil];
//        paymentSheet.delegate = [SLFApplePay share];
//    }
    
    //其次判断设备是否存在绑定过的并支持的银行卡
    /**
     *  若是设备没有支持的银行卡,则进入设置银行卡界面
     *  我这里判断是不支持Visa、银联、Discover等
     */
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkDiscover,PKPaymentNetworkChinaUnionPay]]) {
        
        //进入设置银行卡界面
        [[PKPassLibrary alloc] openPaymentSetup];
    }
    
    NSLog(@"该设备支持ApplePay功能，且wallet存在支持绑定好的银行卡");
    
    //最后，则创建支付请求
    PKPaymentRequest *request = [PKPaymentRequest new];
    
    //填写商户ID（merchant IDs）
    request.merchantIdentifier = @"merchant.com.ztd.applepaytest";
    
    //设置国家代码
    request.countryCode = @"CN"; //中国大陆
    
    //设置支付货币
    request.currencyCode = @"CNY";//人民币
    
    //设置商户的支付标准
    request.merchantCapabilities = PKMerchantCapability3DS; //3DS支付方式是必须支持的，其他方式可选
    
    //设置支持卡的类型
    /**
     *  对支付卡类别的限制
     *  PKPaymentNetworkChinaUnionPay  银联卡
     *  PKPaymentNetworkVisa  国际卡
     *  PKPaymentNetworkMasterCard 万事达卡 国际卡
     *  PKPaymentNetworkDiscover 美国流行的信用卡
     */
    request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkDiscover];
    
    //设置商品参数
    /**
     *  summaryItemWithLabel 商品名称(英文字符默认全部显示大写)
     *  amount 商品的价格 - NSDecimalNumber类型
     *  PKPaymentSummaryItemTypePending 待付款 PKPaymentSummaryItemTypeFinal
     */
    //总价计算
    NSDecimalNumber *itemTotal = [NSDecimalNumber zero];
//收款方
    NSMutableArray * tempItems = [NSMutableArray arrayWithCapacity:1];
    
    for (SLFAPPaymentSummaryItem * item in items) {
        NSDecimalNumber *amout = [NSDecimalNumber decimalNumberWithString:item.price];
        itemTotal = [itemTotal decimalNumberByAdding:amout];

        PKPaymentSummaryItem *itemOne = [PKPaymentSummaryItem summaryItemWithLabel:item.itemName amount:amout];
        [tempItems addObject:itemOne];
    }
//    NSDecimalNumber *oneAmout = [NSDecimalNumber decimalNumberWithString:@"0.01"];
//    NSDecimalNumber *twoAmout = [NSDecimalNumber decimalNumberWithString:@"0.01"];
//    NSDecimalNumber *threemAmout = [NSDecimalNumber decimalNumberWithString:@"0.01"];
//    NSDecimalNumber *itemTotal = [NSDecimalNumber zero];
//    itemTotal = [itemTotal decimalNumberByAdding:oneAmout];
//    itemTotal = [itemTotal decimalNumberByAdding:twoAmout];
//    itemTotal = [itemTotal decimalNumberByAdding:threemAmout];
//    PKPaymentSummaryItem *itemOne = [PKPaymentSummaryItem summaryItemWithLabel:@"物品1"
//                                                                        amount:oneAmout];
//    
//    PKPaymentSummaryItem *itemTwo = [PKPaymentSummaryItem summaryItemWithLabel:@"物品2"
//                                                                        amount:twoAmout];
//    
//    PKPaymentSummaryItem *itemThree = [PKPaymentSummaryItem summaryItemWithLabel:@"物品3"
//                                                                          amount:threemAmout];
//    
    PKPaymentSummaryItem *itemSum = [PKPaymentSummaryItem summaryItemWithLabel:@"孙凌锋" amount:itemTotal];
    [tempItems addObject:itemSum];
    request.paymentSummaryItems = [tempItems mutableCopy];
    /**
     *  以上参数都是必须的
     *  以下参数不是必须的
     */
    
    //设置收据内容
    request.requiredBillingAddressFields = PKAddressFieldAll;  //则其余四个必须添加
    
    //设置送货内容 all则其余四个内容必填
    request.requiredShippingAddressFields = PKAddressFieldAll;
    
    NSMutableArray * tempShipping = [NSMutableArray arrayWithCapacity:1];
    for (SLFAPShippingMethod * sm in shipping) {
        PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:sm.shippingName amount:[NSDecimalNumber decimalNumberWithString:sm.shippingPrice]];
        method.identifier = sm.shippingIdentifier;
        method.detail = sm.shippingTime;
        [tempShipping addObject:method];
    }
    //设置送货方式
//    PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"顺丰" amount:[NSDecimalNumber decimalNumberWithString:@"20.00"]];
//    method.identifier = @"顺丰物流";
//    method.detail = @"1小时到达";
//    
//    PKShippingMethod *method1 = [PKShippingMethod summaryItemWithLabel:@"菜鸟" amount:[NSDecimalNumber decimalNumberWithString:@"100.00"]];
//    method1.identifier = @"菜鸟物流";
//    method1.detail = @"12年到达";
    request.shippingMethods = [tempShipping mutableCopy];
    
    //显示支付界面
    PKPaymentAuthorizationViewController *paymentVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    
    //遵守代理
    paymentVC.delegate = [SLFApplePay share];
    
    if (!paymentVC) return;
    
    [vc presentViewController:paymentVC animated:YES completion:nil];
}

/**
  *  支付的时候回调
  */
#pragma mark - PKPaymentAuthorizationViewControllerDelegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    
    /**
     *  在这个代理方法内部,需支付信息应发送给服务器/第三方的SDK（银联SDK/易宝支付SDK/易智付SDK等）
     *  再根据服务器返回的支付成功与否进行不同的block显示
     *  我这里是直接返回支付成功的结果
     */
    
    completion(PKPaymentAuthorizationStatusSuccess);
    
    NSLog(@"payment --- %@", payment);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
    //支付页面关闭
    //点击支付/取消按钮调用该代理方法
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end


@implementation SLFAPPaymentSummaryItem

-(instancetype)init {
    if (self == [super init]) {
        _itemName = @"物品";
        _price = @"0.01";
    }
    return self;
}

@end

@implementation SLFAPShippingMethod

-(instancetype)init {
    if (self == [super init]) {
        _shippingName = @"顺丰";
        _shippingTime = @"2-3天";
        _shippingPrice = @"20";
        _shippingIdentifier = @"顺丰快递";
    }
    return self;
}

@end

