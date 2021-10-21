/*
 *    HelpshiftCore.h
 *    SDK Version 2.4.1
 *
 *    Get the documentation at http://www.helpshift.com/docs
 *
 */

#import <Foundation/Foundation.h>

@protocol HsApiProvider
- (void) _installForApiKey:(NSString *)apiKey domainName:(NSString *)domainName appID:(NSString *)appID;
- (void) _installForApiKey:(NSString *)apiKey domainName:(NSString *)domainName appID:(NSString *)appID withOptions:(NSDictionary *)optionsDictionary;

- (void) _loginWithIdentifier:(NSString *)identifier withName:(NSString *)name andEmail:(NSString *)email;
- (void) _logout;
- (void) _setName:(NSString *)name andEmail:(NSString *)email;
- (BOOL) _setSDKLanguage:(NSString *)langCode;

@end

@interface HelpshiftCore : NSObject
/**
 *  Initialize the HelpshiftCore class with an instance of the Helpshift service which you want to use.
 *
 *  @param apiProvider An implementation of the HsApiProvider protocol. Current implementors of this service are the HelpshiftCampaigns, HelpshiftSupport and HelpshiftAll classes.
 */
+ (void) initializeWithProvider:(id <HsApiProvider>)apiProvider;

/** Initialize helpshift support
 *
 * When initializing Helpshift you must pass these three tokens. You initialize Helpshift by adding the following lines in the implementation file for your app delegate, ideally at the top of application:didFinishLaunchingWithOptions. This method can throw the InstallException asynchronously if the install keys are not in the correct format or if there is a problem accessing user's keychain (eg. user denies access)
 *
 *  @param apiKey This is your developer API Key
 *  @param domainName This is your domain name without any http:// or forward slashes
 *  @param appID This is the unique ID assigned to your app
 *
 *  @available Available in SDK version 1.0.0 or later
 */
+ (void) installForApiKey:(NSString *)apiKey domainName:(NSString *)domainName appID:(NSString *)appID;

/** Initialize helpshift support
 *
 * When initializing Helpshift you must pass these three tokens. You initialize Helpshift by adding the following lines in the implementation file for your app delegate, ideally at the top of application:didFinishLaunchingWithOptions. This method can throw the InstallException asynchronously if the install keys are not in the correct format or if there is a problem accessing user's keychain (eg. user denies access)
 *
 * @param apiKey This is your developer API Key
 * @param domainName This is your domain name without any http:// or forward slashes
 * @param appID This is the unique ID assigned to your app
 * @param withOptions This is the dictionary which contains additional configuration options for the HelpshiftSDK.
 *
 * @available Available in SDK version 1.0.0 or later
 */

+ (void) installForApiKey:(NSString *)apiKey domainName:(NSString *)domainName appID:(NSString *)appID withOptions:(NSDictionary *)optionsDictionary;

/** Login a user with a given identifier
 *
 * The identifier uniquely identifies the user. Name and email are optional.
 *
 * @param name The name of the user
 * @param email The email of the user
 *
 * @available Available in SDK version 1.0.0 or later
 *
 */
+ (void) loginWithIdentifier:(NSString *)identifier withName:(NSString *)name andEmail:(NSString *)email;

/** Logout the currently logged in user
 *
 * After logout, Helpshift falls back to the default device login.
 *
 * @available Available in SDK version 1.0.0 or later
 *
 */
+ (void) logout;

/** Set the name and email of the application user.
 *
 *
 *   @param name The name of the user.
 *   @param email The email address of the user.
 *
 *   @available Available in SDK version 1.0.0 or later
 */

+ (void) setName:(NSString *)name andEmail:(NSString *)email;

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

/** Get the path of the Helpshift SDK's log file.
 * @return the string representing the path of the SDK's log file.
 */

+ (NSString *) logFilePath;
@end
