//
//  SLFApplePay.h
//  ApplePayText
//
//  Created by SADF on 17/2/17.
//  Copyright © 2017年 LingFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@class SLFAPPaymentSummaryItem;
@class SLFAPShippingMethod;

/**
 苹果支付
 */
@interface SLFApplePay : NSObject<PKPaymentAuthorizationViewControllerDelegate>
/**
 单利

 @return <#return value description#>
 */
+(SLFApplePay *)share;
/**
 填写商户ID（merchant IDs）
 */
@property (nonatomic, copy) NSString * merchantIdentifier;
/**
 设备上是否支持以下银行卡
 */
@property (nonatomic, retain) NSArray<PKPaymentNetwork> * worksCards;
/**
 最后设置完上面开在开始 CN CNY

 @param vc 要展示的控制器
 @param items 销售物品
 @param shipping 输送方式
 */
+(void)startApplePay:(UIViewController *)vc items:(NSArray <SLFAPPaymentSummaryItem *> *)items shipping:(NSArray <SLFAPShippingMethod *> *)shipping;
@end

@interface SLFAPPaymentSummaryItem : NSObject
/**
 物品价格
 */
@property (nonatomic, copy) NSString * price;
/**
 物品名字
 */
@property (nonatomic, copy) NSString * itemName;

@end

@interface SLFAPShippingMethod : NSObject
/**
 输送方 名字
 */
@property (nonatomic, copy) NSString * shippingName;
/**
 运费
 */
@property (nonatomic, copy) NSString * shippingPrice;
/**
 输送时间
 */
@property (nonatomic, copy) NSString * shippingTime;
/**
 唯一标示符
 */
@property (nonatomic, copy) NSString * shippingIdentifier;
@end
