#  Steps

Create tasks for participants to perform.

## Overview

Using ResearchKit, you can build apps that obtain consent, give instructions, present a form or survey, or run an active task. You create all of these interactions with a collection of steps. Steps are based on ``ORKStep`` and are the building blocks of tasks.

## Topics

### Essentials

- ``ORKStep``

### Active steps

- ``ORKActiveStep``
- ``ORKMotionActivityCollector``
- ``ORKMotionActivityPermissionType``

### Authentication and consent steps

- ``ORKLoginStep``
- ``ORKSignatureStep``
- ``ORKVerificationStep``
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

### Custom steps

- ``ORKCustomStep``

### Family History

- ``ORKFamilyHistoryStep``
- ``ORKConditionStepConfiguration``
- ``ORKHealthCondition``
- ``ORKRelatedPerson``
- ``ORKRelativeGroup``

### Form steps

- ``ORKFormStep``
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

- ``ORKFrontFacingCameraStep``
- ``ORKImageCaptureStep``

### Location steps

- ``ORKLocation``
- ``ORKLocationPermissionType``

### Passcode steps

- ``ORKPasscodeStep``
- ``ORKPasscodeFlow``
- ``ORKPasscodeType``

### PDF and page steps

- ``ORKPDFViewerStep``
- ``ORKPageStep``
- ``ORKPDFViewerActionBarOption``

### Question and instruction steps

- ``ORKQuestionStep``
- ``ORKInstructionStep``
- ``ORKLearnMoreInstructionStep``
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

### Step recording

- ``ORKRecorder``
- ``ORKRecorderDelegate``
- ``ORKFileProtectionMode``

### Table steps

- ``ORKTableStep``
- ``ORKTableStepSource``

### Video steps

- ``ORKVideoCaptureStep``
- ``ORKVideoInstructionStep``

### Vision steps

- ``ORKAmslerGridEyeSide``

### Wait steps

- ``ORKWaitStep``

### Web steps

- ``ORKWebViewStep``

### Other steps

- ``ORKSecondaryTaskStep``
- ``ORKSkipStepNavigationRule``
