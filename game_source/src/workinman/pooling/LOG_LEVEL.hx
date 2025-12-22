package workinman.pooling;

enum LOG_LEVEL {
	NONE;			// No logging
	NO_STACK;		// Notifications on reuse and creation
	NEW_STACK; 		// Include stack on new instances
	ALL_STACK;		// Include stack on reuse and new instances
}
