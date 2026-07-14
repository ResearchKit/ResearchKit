# Serializing ResearchKit objects

Use the ``ORKESerializer`` to encode and decode ResearchKit tasks and results.

## Overview

The ``ORKESerializer`` is the class responsible for decoding and encoding ``ResearchKit`` objects. Making use of the serializer enables a number of possibilities for your app:

- Store JSON task definitions remotely and decode them app-side
- Encode task results to JSON and upload them to a remote server
- Encode task results to `NSData` and store them on device for later use

### Entry Provider System

Before using the serializer, it's important to understand the entry provider system. The ``ORKESerializer`` requires a list of ``ORKSerializationEntryProvider`` instances to be provided before any encoding or decoding can happen. Each entry provider registers ``ResearchKit`` classes and defines how their properties should be serialized and deserialized. Two entry providers are provided for you.

* **ORKCoreSerializationEntryProvider**
* **ORKActiveTaskSerializationEntryProvider**

The core entry provider contains any serializable ``ResearchKit`` class that lives in the core (`ResearchKit`) module of the framework. The active task entry provider contains any serializable ``ResearchKit`` class that lives in the active task (`ResearchKitActiveTask`) module of the framework.

Together, these entry providers ensure that tasks and results can be converted to JSON and back to their original object form without data loss. Unless you create your own entry provider, these two classes should handle all of your serialization needs with ``ResearchKit``.


### Using the Serializer

#### 1. Create the serializer

To create the serializer, initialize the necessary entry providers and pass those to the ``ORKESerializer`` during its initialization.

```swift
let coreEntryProvider = ORKCoreSerializationEntryProvider()
let activeTaskEntryProvider = ORKActiveTaskSerializationEntryProvider()
let serializer = ORKESerializer(entryProviders: [coreEntryProvider, activeTaskEntryProvider])
```


#### 2. Serialize ResearchKit objects to JSON

This example uses the ORKInstructionStep below and encodes to JSON.

```swift
let instructionStep = ORKInstructionStep(identifier: "id")
instructionStep.text = "text"
instructionStep.title = "title"
instructionStep.detailText = "detailText"
```

Using the serializer initialized in step 1, encode the instruction step to a JSON object:

```swift
do {
	let instructionStepJSON = try serializer.jsonObject(for: instructionStep)
} catch {
	print("Serialization failed: \(error.localizedDescription)")
}
```

The resulting JSON object looks like this:

```json
{
"_class" : "ORKInstructionStep",
"detailText" : "detailText",
"identifier" : "id",
"text" : "text",
"title" : "title"
}
```

#### 3. Deserialize JSON to ResearchKit objects

This example decodes the instruction step JSON created in step 2 to an ORKInstructionStep.

Assuming the JSON object is stored in a file, the code block below shows how to load the file and decode its contents.

```swift
do {
	let data = try Data(contentsOf: URL(fileURLWithPath: path))
	let serializer: ORKESerializer = .init(entryProviders: [
	    ORKCoreSerializationEntryProvider(),
	    ORKActiveTaskSerializationEntryProvider()
	])

	guard let instructionStep = try serializer.object(fromJSONData: data) as? ORKInstructionStep else {
	    print("Failed to cast to ORKInstructionStep")
	    return
	}
	// Use instructionStep here
} catch {
	print("Failed to decode data: \(error.localizedDescription)")
}
```

## Working with Other ResearchKit Objects

The serialization techniques demonstrated in this article apply to all serializable ResearchKit objects, not just steps. The ``ORKESerializer`` can encode and decode tasks such as ``ORKOrderedTask`` and ``ORKNavigableOrderedTask``, as well as results like ``ORKTaskResult`` and ``ORKStepResult``. This makes it easy to store task definitions remotely, upload participant results to a server, or persist data locally for offline use.

