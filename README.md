# Phex data dispatcher

The EVREF experimental server has only one opened port (for security reasons).  
This project aims to dispatch the received data to other servers responsible for the data treatment.

## Installation

```st
Metacello new
  githubUser: 'Pharo-XP-Tools' project: 'Phex-Data-Dispatcher' commitish: 'main' path: 'src';
  baseline: 'PhexDataDispatcher';
  load
```

## Description

`PhexDataDispatcher` is an HTTP server that listens for requests to forward to a given target.

## Prerequisites

Before starting the dispatcher, create a JSON file named "redirections.json" at the root of the image directory.  
This file must declare the redirections to apply as illustrated by the example below.  

`redirections.json`
```
{
	"oldPath" : {
		"host" : "localhost",
		"port" : 4040,
		"path" : "newPath"	
	},
	"path" : {
		"host" : "localhost",
		"port" : 4242,
		"path" : ""	
	},
}
```

For a dispatcher started on the 8080 port, this "redirections.json" example specifies that an incoming request to:  
- `http://localhost:8080/oldPath` must be forwarded to `http://localhost:4040/newPath`.
- `http://localhost:8080/path` must be forwarded to `http://localhost:4242/`

### Good to know

- Be aware, all arguments are mandatory, and if the "redirections.json" file is absent or not formatted as expected, the program is going to crash.  
- If the "redirections.json" declares redirections with identical incoming path, the last one will prevail.
- Modifications to the "redirections.json" will be applied only after a restart of the dispatcher. 

## Usage example

To start a `PhexDataDispatcher` on the port 8080, execute the following snippet:
```
PhexDataDispatcher start: 8080
```

## Possible errors

When the dispatcher receives a request with a path that is undeclared by the "redirections.json" file, it returns a code 500 to the client, with the following message in payload:

"The redirection of /undeclared path is not configured."

## Dependencies

I rely on Zinc-HTTP, in particular `ZnServer` and `ZnClient`.
