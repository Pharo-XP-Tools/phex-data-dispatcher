"
## Description

`PhexDataDispatcher` is an HTTP server that listens for requests to forward to a given target.

## Prerequisites

Before being started its requires a JSON file named ""redirections.json"" at the root of the image directory.
This file must declare the redirections to apply as shown by the following example:

```
{
	""oldPath"" : {
		""host"" : ""localhost"",
		""port"" : 8888,
		""path"" : ""newPath""	
	}
}
```

Be aware, all arguments are mandatory, and if the ""redirections.json"" file is absent or not formatted as expected, the program is going to crash.

## Usage example

To start a `PhexDataDispatcher` on the port 8080, execute the following snippet:
```
PhexDataDispatcher start: 8080
```

## Possible errors

When the dispatcher receives a request with a path that is undeclared in the ""redirections.json"" file, it returns a code 500 to the client, with the following message in payload:

""The redirection of /undeclared path is not configured.""

## Dependencies

I rely on Zinc-HTTP, in particular `ZnServer` and `ZnClient`.
"
Class {
	#name : 'PhexDataDispatcher',
	#superclass : 'Object',
	#instVars : [
		'server',
		'redirections'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Phex-Data-Dispatcher',
	#package : 'Phex-Data-Dispatcher'
}

{ #category : 'accessing' }
PhexDataDispatcher class >> redirections [

	^ STON fromStream: (Smalltalk imageDirectory / 'redirections.json') readStream
]

{ #category : 'accessing' }
PhexDataDispatcher class >> start: aPort [

	instance ifNil: [ instance := self new ].
	instance redirections: self redirections.
	instance start: aPort.
	
	^ instance

	
]

{ #category : 'accessing' }
PhexDataDispatcher class >> stop [

	instance ifNil: [ 
		self error: 'No instance of the dispatcher is running. Use ', (self class >> #start:) name
	].

	instance stop.
	instance := nil.
	
	^ instance
]

{ #category : 'public' }
PhexDataDispatcher >> handleRequest: aRequest [

	| redirection segments |

	redirection := self redirections at: aRequest uri segments first ifAbsent: [ 
		^ ZnResponse serverError: ('The redirection of {1} path is not configured.' format: { aRequest uri })
	].

	segments := OrderedCollection new.
	segments addAllFirst: (((redirection at: #path) splitOn: $/) reject: [ :s | s isEmptyOrNil ]).
	segments addAll: aRequest uri segments copyWithoutFirst.

	^ ZnClient new
		request: aRequest;
		host: (redirection at: #host);
		port: (redirection at: #port);
		path: (segments joinUsing: $/);
		execute;
		response
]

{ #category : 'accessing' }
PhexDataDispatcher >> redirections [

	^ redirections
]

{ #category : 'accessing' }
PhexDataDispatcher >> redirections: aDictionary [

	redirections := aDictionary 
]

{ #category : 'accessing' }
PhexDataDispatcher >> start: aPort [

	server := ZnServer on: aPort.
	server delegate: self.
	server start

]

{ #category : 'accessing' }
PhexDataDispatcher >> stop [

	server stop
]
