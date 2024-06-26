#  Steps

Create tasks for participants to perform.

## Overview

Using ResearchKit, you can build apps that obtain consent, give instructions, present a form or survey, or run an active task. You create all of these interactions with a collection of steps. Steps are based on ``ORKStep`` and are the building blocks of tasks.

## Topics

### Essentials

- ``ORKStep``
- ``ORKStepViewController``
- ``ORKStepViewControllerDelegate``

### Active steps

- ``ORKActiveStep``
- ``ORKActiveStepViewController``
- ``ORKMotionActivityCollector``
- ``ORKMotionActivityPermissionType``
- ``ORKHolePegTestSample``
- ``ORKEnvironmentSPLMeterStep``
- ``ORKBodySagittal``

### Authentication and consent steps

- ``ORKLoginStep``
- ``ORKLoginStepViewController``
- ``ORKSignatureStep``
- ``ORKVerificationStep``
- ``ORKVerificationStepViewController``
- ``ORKLoginFormItemIdentifierEmail``
- ``ORKLoginFormItemIdentifierPassword``
- ``ORKKeychainWrapper``

### Permissions

- ``ORKPermissionType``
- ``ORKHealthKitPermissionType``
- ``ORKSensorPermissionType``
- ``SRSensor``
- ``ORKPermissionMask``
- ``ORKNotificationPermissionType``
- ``ORKRequestPermissionsStep``
- ``ORKBiologicalSexIdentifier``
- ``ORKBloodTypeIdentifier``

### Consent and completion steps

- ``ORKConsentReviewStep``
- ``ORKConsentSharingStep``
- ``ORKCompletionStep``
- ``ORKCompletionStepViewController``
- ``ORKCompletionStepIdentifier``

### Custom steps

- ``ORKCustomStep``
- ``ORKCustomStepViewController``

### Form steps

- ``ORKFormStep``
- ``ORKFormStepViewController``
- ``ORKBodyItem``
- ``ORKBulletType``
- ``ORKBodyItemStyle``
- ``ORKFormItem``
- ``ORKNoAnswer``
- ``ORKDontKnowAnswer``
- ``ORKDontKnowButtonStyle``
- ``ORKCardViewStyle``
- ``ORKLearnMoreItem``

### Image and 3D model steps

- ``ORK3DModelStep``
- ``ORK3DModelManager``
- ``ORKUSDZModelManager``
- ``ORK3DModelManagerProtocol``
- ``ORKFrontFacingCameraStep``
- ``ORKImageCaptureStep``
- ``ORKPlaybackButton``

### Location steps

- ``ORKLocation``
- ``ORKLocationPermissionType``
- ``ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION``

### Passcode steps

- ``ORKPasscodeStep``
- ``ORKPasscodeViewController``
- ``ORKPasscodeDelegate``
- ``ORKPasscodeFlow``
- ``ORKPasscodeType``

### PDF and page steps

- ``ORKPDFViewerStep``
- ``ORKPDFViewerStepViewController``
- ``ORKPageStep``
- ``ORKPageStepViewController``
- ``ORKPDFViewerActionBarOption``

### Question and instruction steps

- ``ORKQuestionStep``
- ``ORKInstructionStep``
- ``ORKInstructionStepViewController``
- ``ORKLearnMoreInstructionStep``
- ``ORKLearnMoreStepViewController``
- ``ORKNavigablePageStep``

### Registration steps

- ``ORKRegistrationStep``
- ``ORKRegistrationStepOption``
- ``ORKRegistrationFormItemIdentifierDOB``
- ``ORKRegistrationFormItemIdentifierEmail``
- ``ORKRegistrationFormItemIdentifierFamilyName``
- ``ORKRegistrationFormItemIdentifierGender``
- ``ORKRegistrationFormItemIdentifierGivenName``
- ``ORKRegistrationFormItemIdentifierPassword``
- ``ORKRegistrationFormItemIdentifierPhoneNumber``

### Review steps

- ``ORKReviewStep``
- ``ORKReviewViewController``
- ``ORKReviewViewControllerDelegate``

### Step recording

- ``ORKRecorder``
- ``ORKRecorderDelegate``
- ``ORKFileProtectionMode``

### Table steps

- ``ORKTableStep``
- ``ORKTableStepViewController``
- ``ORKTableStepSource``

### Video steps

- ``ORKVideoCaptureStep``
- ``ORKVideoInstructionStep``

### Vision steps

- ``ORKAmslerGridEyeSide``

### Wait steps

- ``ORKWaitStep``
- ``ORKWaitStepViewController``

### Web steps

- ``ORKWebViewStep``
- ``ORKWebViewStepDelegate``
- ``ORKWebViewStepViewController``

### Other steps

- ``ORKSecondaryTaskStep``
- ``ORKSkipStepNavigationRule``
- ``ORKTouchAnywhereStep``
- ``ORKTouchAnywhereStepViewController``
- ``ORKAccuracyStroopStep``

