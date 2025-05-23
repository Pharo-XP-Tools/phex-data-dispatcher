Class {
	#name : 'PXDataDispatcher',
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
PXDataDispatcher class >> redirections [

	^ STON fromStream: (self repository 
		location / 
		'configuration' /
		'redirections.json'
	) readStream
]

{ #category : 'accessing' }
PXDataDispatcher class >> repository [

	^ IceRepository repositories detect: [ :r |
		(r workingCopy packages collect: [ :p | p name ]) includes: self package name 
	]
]

{ #category : 'accessing' }
PXDataDispatcher class >> start: aPort [

	instance ifNil: [ instance := self new ].
	instance redirections: self redirections.
	instance start: aPort

	
]

{ #category : 'accessing' }
PXDataDispatcher class >> stop [

	instance ifNil: [ 
		self error: 'No instance of the dispatcher is running. Use PXDataDispatcher class >> #start'
	].

	instance stop
]

{ #category : 'public' }
PXDataDispatcher >> handleRequest: aRequest [

	| redirection segments |

	redirection := self redirections at: aRequest uri segments first ifAbsent: [ 
		^ ZnResponse serverError: ('Phex redirection to {1} not configured.' format: { aRequest uri })
	].

	segments := OrderedCollection new.
	segments addAllFirst: (((redirection at: #path) splitOn: $/) reject: [ :s | s isEmptyOrNil ]).
	segments addAll: aRequest uri segments copyWithoutFirst.

	aRequest uri segments: segments.

	^ ZnClient new
		request: aRequest;
		host: (redirection at: #host);
		port: (redirection at: #port);
		execute;
		response
]

{ #category : 'accessing' }
PXDataDispatcher >> redirections [

	^ redirections
]

{ #category : 'accessing' }
PXDataDispatcher >> redirections: aDictionary [

	redirections := aDictionary 
]

{ #category : 'accessing' }
PXDataDispatcher >> start: aPort [

	server := ZnServer on: aPort.
	server delegate: self.
	server start

]

{ #category : 'accessing' }
PXDataDispatcher >> stop [

	server stop
]
