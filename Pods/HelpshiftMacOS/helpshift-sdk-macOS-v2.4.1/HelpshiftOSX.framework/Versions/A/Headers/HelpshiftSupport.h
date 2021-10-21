/*
 *    HelpshiftSupport.h
 *    SDK Version 2.4.1
 *
 *    Get the documentation at http://www.helpshift.com/docs
 *
 */

#import <Foundation/Foundation.h>
#import "HelpshiftCore.h"

typedef enum HelpshiftSupportAlertToRateAppAction
{
    HelpshiftSupportAlertToRateAppActionClose = 0,
    HelpshiftSupportAlertToRateAppActionFeedback,
    HelpshiftSupportAlertToRateAppActionSuccess,
    HelpshiftSupportAlertToRateAppActionFail
} HelpshiftSupportAlertToRateAppAction;

typedef NSDictionary * (^HelpshiftSupportMetadataBlock)(void);
typedef void (^HelpshiftSupportAppRatingAlertViewCompletionBlock)(HelpshiftSupportAlertToRateAppAction);

extern NSString *const HelpshiftOSXNotificationIdentifier;

// A Reserved key (HelpshiftSupportCustomMetadataKey) constant to be used in options dictionary of showFAQs, showConversation, showFAQSection, showSingleFAQ to
// provide a dictionary for custom data to be attached along with new conversations.
//
// If you want to attach custom data along with new conversation, use this constant key and a dictionary value containing the meta data key-value pairs
// and pass it in withOptions param before calling any of the 4 support APIs.
//
// Available in SDK version 1.0.0 or later
//
// Example usages:
//  NSDictionary *metaDataWithTags = @{@"usertype": @"paid", @"level":@"7", @"score":@"12345", HelpshiftSupportTagsKey:@[@"feedback",@"paid user",@"v4.1"]};
//  [[Helpshift sharedInstance] showFAQs:self withOptions:@{@"gotoConversationAfterContactUs":@"YES", HelpshiftSupportCustomMetadataKey: metaDataWithTags}];
//
//  NSDictionary *metaData = @{@"usertype": @"paid", @"level":@"7", @"score":@"12345"]};
//  [[Helpshift sharedInstance] showConversation:self withOptions:@{HelpshiftSupportCustomMetadataKey: metaData}];
//
extern NSString *const HelpshiftSupportCustomMetadataKey;


// A Reserved key (HelpshiftSupportTagsKey) constant to be used with metadataBlock (of type NSDictionary) to pass NSArray (of type only NSStrings)
// which get interpreted at server and added as Tags for the issue being reported.
// If an object in NSArray is not of type NSString then the object will be removed from Tags and will not be added for the issue.
//
// Available in SDK version 1.0.0 or later
// Example usage 1:
//    [Helpshift metadataWithBlock:^(void){
//        return [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"feedback", @"paid user",nil], HelpshiftSupportTagsKey, nil];
//    }];
// Example usage 2 (Available in SDK version 1.0.0 or later):
//    NSDictionary *metaData = @{@"usertype": @"paid", @"level":@"7", @"score":@"12345", HelpshiftSupportTagsKey:@[@"feedback",@"paid user",@"v4.1"]};
//    [[Helpshift sharedInstance] showConversation:self withOptions:@{HelpshiftSupportCustomMetadataKey: metaData}];
//
extern NSString *const HelpshiftSupportTagsKey;

// String constant to check which type of message you get in userRepliedToConversationWithMessage: delegate.
// When you use userRepliedToConversationWithMessage: delegate, you can check the type of message user replied with.
// When user replied with text message you will get that message string in delegate method.
// Example usage 1:
// - (void) userRepliedToConversationWithMessage:(NSString *)newMessage {
//   if ([newMessage isEqualToString:HelpshiftSupportUserAcceptedTheSolution]) {
//    // do something here
//    }
// }

static NSString *HelpshiftSupportUserAcceptedTheSolution = @"User accepted the solution";
static NSString *HelpshiftSupportUserRejectedTheSolution = @"User rejected the solution";
static NSString *HelpshiftSupportUserSentScreenShot = @"User sent a screenshot";
static NSString *HelpshiftSupportUserReviewedTheApp = @"User reviewed the app";


static NSString *HelpshiftSupportConversationFlow = @"conversationFlow";
static NSString *HelpshiftSupportFAQsFlow = @"faqsFlow";
static NSString *HelpshiftSupportFAQSectionFlow = @"faqSectionFlow";
static NSString *HelpshiftSupportSingleFAQFlow = @"singleFaqFlow";

/**
 * This document describes the API exposed by the Helpshift SDK which the developers can use to integrate Helpshift support into their iOS applications. If you want documentation regarding how to use the various features provided by the Helpshift SDK, please visit the [developer docs](http://developers.helpshift.com/)
 */

@protocol HelpshiftSupportDelegate;

@interface HelpshiftSupport : NSObject <HsApiProvider> {
    id <HelpshiftSupportDelegate> delegate;
}

@property (nonatomic, retain) id<HelpshiftSupportDelegate> delegate;

/** Returns an instance of Helpshift
 *
 * When calling any Helpshift instance method you must use sharedInstance. For example to call showSupport: you must call it like [[Helpshift sharedInstance] showSupport:self];
 *
 * @available Available in SDK version 1.0.0 or later
 */
+ (HelpshiftSupport *) sharedInstance;

/** Change the SDK language. By default, the device's prefered language is used.
 *  If a Helpshift session is already active at the time of invocation, this call will fail and will return false.
 *
 * @param languageCode the string representing the language code. For example, use 'fr' for French.
 *
 * @return BOOL indicating wether the specified language was applied. In case the language code is incorrect or
 * the corresponding localization file was not found, bool value of false is returned and the default language is used.
 *
 * @available Available in SDK version 1.0.0 or later
 */
+ (BOOL) setSDKLanguage:(NSString *)languageCode;

/** Show the helpshift conversation screen (with Optional Arguments)
 *
 * To show the Helpshift conversation screen with optional arguments you will need to pass the name of the viewcontroller on which the conversation screen will show up and an options dictionary. If you do not want to pass any options then just pass nil which will take on the default options.
 *
 * @param viewController viewController on which the helpshift report issue screen will show up.
 * @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift conversation session (that will start with this method call).
 *
 * Please check the docs for available options.
 *
 * @available Available in SDK version 1.0.0 or later
 */
+ (void) showConversationWithOptions:(NSDictionary *)optionsDictionary;

/** Show the support screen with only the faqs (with Optional Arguments)
 *
 * To show the Helpshift screen with only the faq sections with search with optional arguments, you can use this api. If you do not want to pass any options then just pass nil which will take on the default options.
 *
 * @param viewController viewController on which the helpshift faqs screen will show up.
 * @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift faqs screen session (that will start with this method call).
 *
 * Please check the docs for available options.
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (void) showFAQsWithOptions:(NSDictionary *)optionsDictionary;

/** Show the helpshift screen with faqs from a particular section
 *
 * To show the Helpshift screen for showing a particular faq section you need to pass the publish-id of the faq section and the name of the viewcontroller on which the faq section screen will show up. For example from inside a viewcontroller you can call the Helpshift faq section screen by passing the argument “self” for the viewController parameter. If you do not want to pass any options then just pass nil which will take on the default options.
 *
 * @param faqSectionPublishID the publish id associated with the faq section which is shown in the FAQ page on the admin side (__yourcompanyname__.helpshift.com/admin/faq/).
 * @param viewController viewController on which the helpshift faq section screen will show up.
 * @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift session (that will start with this method call).
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (void) showFAQSection:(NSString *)faqSectionPublishID withOptions:(NSDictionary *)optionsDictionary;

/** Show the helpshift screen with a single faq
 *
 * To show the Helpshift screen for showing a single faq you need to pass the publish-id of the faq and the name of the viewcontroller on which the faq screen will show up. For example from inside a viewcontroller you can call the Helpshift faq section screen by passing the argument “self” for the viewController parameter. If you do not want to pass any options then just pass nil which will take on the default options.
 *
 * @param faqPublishID the publish id associated with the faq which is shown when you expand a single FAQ (__yourcompanyname__.helpshift.com/admin/faq/)
 * @param viewController viewController on which the helpshift faq section screen will show up.
 * @param optionsDictionary the dictionary which will contain the arguments passed to the Helpshift session (that will start with this method call).
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (void) showSingleFAQ:(NSString *)faqPublishID withOptions:(NSDictionary *)optionsDictionary;

/** Show alert for app rating
 *
 * To manually show an alert for app rating, you need automated reviews disabled in admin.
 * Also, if there is an ongoing conversation, the review alert will not show up.
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (void) showAlertToRateAppWithURL:(NSString *)url;

/** Set an user identifier for your users.
 *
 * This is part of additional user configuration. The user identifier will be passed through to the admin dashboard as "User ID" under customer info.
 *  @param userIdentifier A string to identify your users.
 *
 *  @available Available in SDK version 1.0.0 or later
 */

+ (void) setUserIdentifier:(NSString *)userIdentifier;

/** Add extra debug information regarding user-actions.
 *
 * You can add additional debugging statements to your code, and see exactly what the user was doing right before they reported the issue.
 *
 *  @param breadCrumbString The string containing any relevant debugging information.
 *
 *  @available Available in SDK version 1.0.0 or later
 */

+ (void) leaveBreadCrumb:(NSString *)breadCrumbString;

/** Provide a block which returns a dictionary for custom meta data to be attached along with new conversations
 *
 * If you want to attach custom data along with any new conversation, use this api to provide a block which accepts zero arguments and returns an NSDictionary containing the meta data key-value pairs. Everytime an issue is reported, the SDK will call this block and attach the returned meta data dictionary along with the reported issue. Ideally this metaDataBlock should be provided before the user can file an issue.
 *
 *  @param metadataBlock a block variable which accepts zero arguments and returns an NSDictionary.
 *
 *  @available Available in SDK version 1.0.0 or later
 */

+ (void) setMetadataBlock:(HelpshiftSupportMetadataBlock)metadataBlock;

/** Get the notification count for replies to new conversations.
 *
 *
 * If you want to show your user notifications for replies on any ongoing conversation, you can get the notification count asynchronously by implementing the HelpshiftSupportDelegate in your respective .h and .m files.
 * Use the following method to set the delegate, where self is the object implementing the delegate.
 * [[Helpshift sharedInstance] setDelegate:self];
 * Now you can call the method
 * [[Helpshift sharedInstance] getNotificationCountFromRemote:YES];
 * This will return a notification count in the
 * - (void) didReceiveNotificationCount:(NSInteger)count
 * count delegate method.
 * If you want to retrieve the current notification count synchronously, you can call the same method with the parameter set to false, i.e
 * NSInteger count = [[Helpshift sharedInstance] getNotificationCountFromRemote:NO]
 *
 * @param isRemote Whether the notification count is to be returned asynchronously via delegate mechanism or synchronously as a return val for this api
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (NSInteger) getNotificationCountFromRemote:(BOOL)isRemote;

+ (void) clearBreadCrumbs;

/**
 * Update the theme used in the Helpshift SDK.
 * This API will try and read the theme file from the main bundle of the app
 * Updating the theme will fail if the SDK session is already active.
 *
 * @available Available in SDK version 2.3.0 or later
 * @param plistFileName plist file name which corresponds to the new/alternate theme for the SDK
 * @return return YES if the theme has been switched, NO otherwise
 */
+ (BOOL) updateThemeFromFile:(NSString *)plistFileName;

@end

@protocol HelpshiftSupportDelegate <NSObject>

@optional

/** Delegate method call that should be implemented if you are calling getNotificationCountFromRemote:YES
 * @param count Returns the number of unread messages for the ongoing conversation
 *
 * @available Available in SDK version 1.0.0 or later
 */

- (void) didReceiveNotificationCount:(NSInteger)count;

/** Optional delegate method that is called when the a Helpshift session begins.
 *
 *
 * Helpshift session is any Helpshift support screen opened via showFAQ:, showConversation: or other API calls.
 * Whenever one of these APIs launches a view on screen, this method is invoked.
 *
 *  @available Available in SDK version 1.0.0 or later
 */
- (void) helpshiftSupportSessionHasBegun;

/** Optional delegate method that is called when the Helpshift session ends.
 *
 *
 * Helpshift session is any Helpshift support screen opened via showSupport: or other API calls.
 * Whenever the user closes that support screen and returns back to the app this method is invoked.
 *
 *  @available Available in SDK version 1.0.0 or later
 */
- (void) helpshiftSupportSessionHasEnded;

/** Optional delegate method that is called when a Helpshift inapp notification arrives and is shown
 *  @param count Returns the number of messages that has arrived via inapp notification.
 *
 * @available Available in SDK version 1.0.0 or later
 */
- (void) didReceiveInAppNotificationWithMessageCount:(NSInteger)count;

/** Optional delegate method that is called when new conversation get started via any Helpshift API Ex:- showFaq:, showConversation:,etc
 * @param newConversationMessage Return first message of new conversation.
 * @available Available in SDK version 1.0.0 or later
 */
- (void) newConversationStartedWithMessage:(NSString *)newConversationMessage;

/** Optional delegate method that is called when user reply on current open conversation via any Helpshift API Ex:- showFaq:, showConversation:, etc
 * @param newMessage Return reply message on open conversation.
 * @available Available in SDK version 1.0.0 or later
 */
- (void) userRepliedToConversationWithMessage:(NSString *)newMessage;

/**Optional delegate method that is called when user complete customer satisfaction survey after issue getting resolved.
 * @param rating Return the rating of customer satisfaction survey.
 * @param feedback Return text which user added in customer satisfaction survey.
 *
 * @available Available in SDK version 1.0.0 or later.
 */
- (void) userCompletedCustomerSatisfactionSurvey:(NSInteger)rating withFeedback:(NSString *)feedback;

@end
