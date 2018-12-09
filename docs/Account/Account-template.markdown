# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# The Account Module
Registration is an important aspect of validating users of your ResearchKit app. The Account module provides all of the logic to perform this necessary functionality.

The basic operations of the Account module include:

 * Registration, during which the user can enter an email address, password, and additional information such as first and last name, gender, and date of birth.
 * Verification, when your app can vet new users. In order to properly vet new users, your app can opt to perform a verification step after registration.
 * Login, which allows registered and verified users to access your app. After your user has registered and verified their registration, this operation allows them to log in to your app.

##Register New Users
To register new users, use the `ORKRegistrationStep` class. The resulting view shows a title and helpful registration text. There, the user can type an email address and password, along with other optional information.

The following example specifies a registration step that includes requesting the user's full name, gender, and birthday:

    ORKRegistrationStep *registrationStep = [[ORKRegistrationStep alloc] initWithIdentifier:@"identifier"
                                                                                      title:@"Account Registration" text:@"Please register at this point."
                                                                                    options:ORKRegistrationStepIncludeGivenName |                                             ORKRegistrationStepIncludeFamilyName | ORKRegistrationStepIncludeGender |ORKRegistrationStepIncludeDOB];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"registrationTask" steps:@[registrationStep]];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:^{}];


Figure 1 shows the registration view.

<center>
<figure>
<img src="Registration.png" width="25%" style="border: solid black 1px;"  align="middle"/>
<figcaption><center>Figure 1. Registration</center></figcaption>
</figure>
</center>

After all of the information has been properly set, the user can touch the Done button to proceed. Your app is responsible for sending the user-provided data to a server to perform the actual registration.

##Verify Users
Email verification is a common way to validate proper registration for a user. After the user registers, your backend server can send an email to the provided email address.

To enable email verification in your app, use a combination of the `ORKVerificationStep` class along with a subclass of the `ORKVerificationStepViewController`. Subclassing `ORKVerificationStepViewController` allows you to provide custom behavior when the user taps the Resend Email Verification button. Here's how to set up your subclass:

	@interface MyVerificationStepViewController : ORKVerificationStepViewController
	@end

	@implmentation MyVerificationStepViewController

	- (void)resendEmailButtonTapped {
   		// perform custom logic here 
	}

	@end

Next, create a verification step and pass in the subclass object:

    ORKVerificationStep *verificationStep = [[ORKVerificationStep alloc] initWithIdentifier:@"identifier"
                                                                                       text:@"Please verify."
                                                            verificationViewControllerClass:[MyVerificationStepViewController class]];

You can then insert the step into your `ORKOrderedTask` object. When the step is executed, it instantiates the view controller, as shown in Figure 2.

<center>
<figure>
<img src="Verification.png" width="25%" style="border: solid black 1px;"  align="middle"/>
<figcaption><center>Figure 2. Verification</center></figcaption>
</figure>
</center>

##Allow Users to Login
After the user has registered and has been verified, you can provide them access to further functionality in your app by helping them log in.

Logging in requires subclassing the `ORKLoginStepViewController` class, which is similar to what you did to implement the verification step. Override the following method in your subclass so that you can add custom logic to handle the situation when the user forgets their password:

	- (void)forgotPasswordButtonTapped;


Here's a code snippet that shows how to create a subclass of `ORKLoginStepViewController`:

	@interface MyLoginStepViewController : ORKLoginStepViewController
	@end

	@implmentation MyLoginStepViewController

	- (void)forgotPasswordButtonTapped {
   		// perform custom logic here 
	}

	@end

When the login step executes, the view shown in Figure 3 appears.

<center>
<figure>
<img src="Login.png" width="25%" style="border: solid black 1px;"  align="middle"/>
<figcaption><center>Figure 3. User login</center></figcaption>
</figure>
</center>
