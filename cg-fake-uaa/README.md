[![Build Status](https://travis-ci.org/18F/cg-fake-uaa.svg?branch=master)](https://travis-ci.org/18F/cg-fake-uaa)
[![Code Climate](https://codeclimate.com/github/18F/cg-fake-uaa/badges/gpa.svg)](https://codeclimate.com/github/18F/cg-fake-uaa)

This is a fake User Account and Authentication ([UAA][]) server for
cloud.gov, useful for development and debugging.

![Screenshot](https://cloud.githubusercontent.com/assets/124687/16729463/9cd1b676-473a-11e6-98f1-588308c0a213.png)

## Motivation

[Authenticating with cloud.gov][cgauth] can be challenging when developing
an app:

* It can be difficult or impossible to log in as multiple different
  users to manually test your application's functionality.
* If you're offline or on a spotty internet connection, authenticating
  with cloud.gov may be challenging.
* Because logging into cloud.gov usually involves 2 factor authentication,
  logging in can be slow and cumbersome, which can slow down
  development.
* At present, registering a new client ID, client secret, and callback URL
  with cloud.gov requires inconveniencing a cloud.gov administrator, as
  there's not yet a self-serve option for registering new apps.
* Debugging problems with the OAuth2 handshake can be difficult because
  you don't have much visibility into cloud.gov's internal state.

The fake UAA is intended to solve these problems by making it easy to
host your own UAA server on your local system.  The simplicity of its
implementation and its debugging messages allow developers to easily
understand what's going on during the OAuth2 handshake.  It also makes
it dead simple to log in as multiple different users.

## Usage

To use this fake UAA, just [download the latest release][download],
uncompress the archive, and run the binary in it:

```
./fake-cloud.gov
```

The output of this command will help you set things up from there.

## Build Requirements

* Go 1.6

Once built, the executable binary is fully self-contained and can be
distributed freely.

## Development Quick Start

First, get dependencies:

```
go get -d ./...
go get -u github.com/jteeuwen/go-bindata/...
```

Then generate and build:

```
go generate
go build
```

Finally, run the server:

```
./cg-fake-uaa
```

During development, you can define `FAKECLOUDGOV_DEBUG=yup` to make
the server fetch data files from the `data` directory instead of using
the files embedded into the executable at build time.

To learn about changing any of the runtime options, run
`./fake-cloud.gov -help`.

## Running Tests

```
go test
```

## Running the Example Client

A node-based example OAuth2 client is in the `example-client` directory.
To use it, run:

```
cd example-client
npm install
npm start
```

Then visit http://localhost:8000/.

Note that the server, `./fake-cloud.gov`, must also be running in order
for the client to work.

## Limitations

The fake server currently has a lot of limitations, most notably:

* Only the [`openid` scope][] is supported. That is, the server is
  only really built for giving you the logged-in user's email
  address.

[download]: https://github.com/18F/cg-fake-uaa/releases
[cgauth]: https://docs.cloud.gov/apps/leveraging-authentication/
[UAA]: https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-APIs.rst
[`openid` scope]: https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-APIs.rst#scopes-authorized-by-the-uaa
