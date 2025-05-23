Class {
	#name : 'BaselineOfPhexDataDispatcher',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPhexDataDispatcher',
	#package : 'BaselineOfPhexDataDispatcher'
}

{ #category : 'baselines' }
BaselineOfPhexDataDispatcher >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: #'Phex-Data-Dispatcher'.
	] 
]
